import Foundation
import CoreLocation
import MapKit

class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()

    @Published var searchResults: [LocationResult] = []
    @Published var isSearching: Bool = false
    @Published var errorMessage: String?

    private let geocoder = CLGeocoder()
    private var searchCompleter: MKLocalSearchCompleter?
    private var searchTask: Task<Void, Never>?

    override init() {
        super.init()
        setupSearchCompleter()
    }

    private func setupSearchCompleter() {
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter?.resultTypes = .address
    }

    func searchLocations(query: String) {
        searchTask?.cancel()

        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        errorMessage = nil

        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 300_000_000)

                guard !Task.isCancelled else { return }

                let placemarks = try await geocoder.geocodeAddressString(query)

                await MainActor.run {
                    self.searchResults = placemarks.compactMap { placemark in
                        guard let location = placemark.location else { return nil }
                        return LocationResult(
                            name: formatPlacemarkName(placemark),
                            coordinate: location.coordinate,
                            timezone: placemark.timeZone ?? TimeZone.current
                        )
                    }
                    self.isSearching = false
                }
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        self.errorMessage = "Could not find location"
                        self.searchResults = []
                        self.isSearching = false
                    }
                }
            }
        }
    }

    func getTimezone(for coordinate: CLLocationCoordinate2D) async -> TimeZone {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.timeZone ?? TimeZone.current
        } catch {
            return TimeZone.current
        }
    }

    func clearSearch() {
        searchTask?.cancel()
        searchResults = []
        isSearching = false
        errorMessage = nil
    }
}

private func formatPlacemarkName(_ placemark: CLPlacemark) -> String {
    var components: [String] = []

    if let locality = placemark.locality {
        components.append(locality)
    }

    if let administrativeArea = placemark.administrativeArea {
        components.append(administrativeArea)
    }

    if let country = placemark.country {
        components.append(country)
    }

    if components.isEmpty {
        return placemark.name ?? "Unknown Location"
    }

    return components.joined(separator: ", ")
}

struct LocationResult: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let timezone: TimeZone

    static func == (lhs: LocationResult, rhs: LocationResult) -> Bool {
        lhs.id == rhs.id
    }
}
