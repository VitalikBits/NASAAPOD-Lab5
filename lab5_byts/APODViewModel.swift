import Combine
import Foundation

@MainActor
final class APODViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case loaded([APODEntry])
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    private let service = NASAAPIService()

    func loadEntries() async {
        // Не запускаємо другий запит, якщо перший ще триває.
        if case .loading = state { return }

        state = .loading

        do {
            let entries = try await service.fetchEntries()

            // Найновіші публікації показуємо першими.
            let sortedEntries = entries.sorted { $0.date > $1.date }
            state = .loaded(sortedEntries)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
