import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StocksViewModel()
    
    var body: some View {
        NavigationView {
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
                        NavigationLink(destination: StockDetailView(symbol: stock.symbol)) {
                            StockRow(stock: stock)
                        }
                        .listRowBackground(AppTheme.backgroundColor)
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
        }
        .task {
            await viewModel.fetchStocks()
        }
    }
}

struct StockRow: View {
    let viewModel: StockRowViewModel
    
    init(stock: StockQuote) {
        self.viewModel = StockRowViewModel(stock: stock)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(viewModel.symbol)
                    .font(.headline)
                    .foregroundColor(AppTheme.textColor)
                Spacer()
                Text(viewModel.closePriceFormatted)
                    .font(.headline)
                    .foregroundColor(viewModel.isPriceUp ? AppTheme.positiveColor : AppTheme.negativeColor)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("O: \(viewModel.openPriceFormatted)")
                        .font(.caption)
                    Text("C: \(viewModel.closePriceFormatted)")
                        .font(.caption)
                }
                .foregroundColor(AppTheme.textColor)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(viewModel.priceChangeText)
                        .font(.caption)
                        .foregroundColor(viewModel.isPriceUp ? AppTheme.positiveColor : AppTheme.negativeColor)
                    HStack(spacing: 4) {
                        Text("H: \(viewModel.highPriceFormatted)")
                        Text("L: \(viewModel.lowPriceFormatted)")
                    }
                    .font(.caption)
                    .foregroundColor(AppTheme.textColor)
                }
            }
        }
        .padding(.vertical, 4)
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