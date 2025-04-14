import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StocksViewModel()
    @State private var selectedSymbol: String?
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.stocks.isEmpty && !viewModel.isLoading {
                    VStack(spacing: 16) {
                        Text("No data available")
                            .font(.headline)
                            .foregroundColor(AppTheme.textColor)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchStocks()
                            }
                        }
                        .foregroundColor(AppTheme.textColor)
                    }
                } else {
                    List(viewModel.stocks) { stock in
                        Button(action: {
                            selectedSymbol = stock.symbol
                        }) {
                            StockRow(stock: stock)
                        }
                        .listRowBackground(AppTheme.backgroundColor)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Stocks")
            .navigationBarTitleTextColor(AppTheme.textColor)
            .background(AppTheme.backgroundColor)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(AppTheme.textColor)
                }
            }
            .refreshable {
                await viewModel.fetchStocks()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("Retry") {
                    Task {
                        await viewModel.fetchStocks()
                    }
                }
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .navigationDestination(item: $selectedSymbol) { symbol in
                StockDetailView(symbol: symbol)
            }
        }
        .task {
            await viewModel.fetchStocks()
        }
    }
}

// Extension for navigation bar title color
extension View {
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(color)]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(color)]
        return self
    }
} 