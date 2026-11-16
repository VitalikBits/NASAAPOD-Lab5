import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject private var viewModel = APODViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("NASA APOD")
                .task {
                    if case .idle = viewModel.state {
                        await viewModel.loadEntries()
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Завантаження публікацій…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let entries):
            if entries.isEmpty {
                Text("Публікацій не знайдено.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(entries) { entry in
                    NavigationLink {
                        APODDetailView(entry: entry)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.title)
                                .font(.headline)

                            Text(entry.date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

        case .failed(let message):
            VStack(spacing: 12) {
                Text("Не вдалося завантажити публікації")
                    .font(.headline)

                Text(message)
                    .foregroundStyle(.secondary)

                Button("Спробувати ще раз") {
                    Task {
                        await viewModel.loadEntries()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
