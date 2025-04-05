import SwiftUI
import Charts

struct StockDetailView: View {
    let symbol: String
    @StateObject private var viewModel = StockDetailViewModel()
    @State private var useCandlestickChart = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let latestQuote = viewModel.historicalData.first {
                    QuoteInfoView(quote: latestQuote)
                }
                
                // Chart type toggle
                HStack {
                    Text("Chart Type:")
                        .foregroundColor(AppTheme.textColor)
                    Spacer()
                    Picker("Chart Type", selection: $useCandlestickChart) {
                        Text("Line").tag(false)
                        Text("Candlestick").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                }
                .padding(.vertical, 8)
                
                // Display the selected chart type
                if useCandlestickChart {
                    CandlestickChart(data: viewModel.historicalData)
                } else {
                    StockPriceChart(data: viewModel.historicalData)
                }
            }
            .padding()
        }
        .navigationTitle(symbol)
        .background(AppTheme.backgroundColor)
        .task {
            await viewModel.fetchHistoricalData(for: symbol)
        }
    }
}

struct QuoteInfoView: View {
    let quote: StockQuote
    
    private var priceChange: Double {
        quote.close - quote.open
    }
    
    private var priceChangePercentage: Double {
        (priceChange / quote.open) * 100
    }
    
    private var volatility: Double {
        ((quote.high - quote.low) / quote.open) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Latest Quote")
                .font(.headline)
                .foregroundColor(AppTheme.textColor)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Close:")
                        .foregroundColor(AppTheme.textColor)
                    Spacer()
                    Text(String(format: "%.2f", quote.close))
                        .foregroundColor(priceChange >= 0 ? AppTheme.positiveColor : AppTheme.negativeColor)
                }
                
                HStack {
                    Text("Change:")
                        .foregroundColor(AppTheme.textColor)
                    Spacer()
                    Text("\(String(format: "%+.2f", priceChange)) (\(String(format: "%+.1f", priceChangePercentage))%)")
                        .foregroundColor(priceChange >= 0 ? AppTheme.positiveColor : AppTheme.negativeColor)
                }
                
                HStack {
                    Text("High:")
                        .foregroundColor(AppTheme.textColor)
                    Spacer()
                    Text(String(format: "%.2f", quote.high))
                        .foregroundColor(AppTheme.textColor)
                }
                
                HStack {
                    Text("Low:")
                        .foregroundColor(AppTheme.textColor)
                    Spacer()
                    Text(String(format: "%.2f", quote.low))
                        .foregroundColor(AppTheme.textColor)
                }
                
                HStack {
                    Text("Volatility:")
                        .foregroundColor(AppTheme.textColor)
                    Spacer()
                    Text("\(String(format: "%.1f", volatility))%")
                        .foregroundColor(AppTheme.textColor)
                }
                
                if let volume = quote.volume {
                    HStack {
                        Text("Volume:")
                            .foregroundColor(AppTheme.textColor)
                        Spacer()
                        Text(formatVolume(volume))
                            .foregroundColor(AppTheme.textColor)
                    }
                }
            }
        }
    }
    
    private func formatVolume(_ volume: Int) -> String {
        if volume >= 1_000_000_000 {
            return String(format: "%.1fB", Double(volume) / 1_000_000_000)
        } else if volume >= 1_000_000 {
            return String(format: "%.1fM", Double(volume) / 1_000_000)
        } else if volume >= 1_000 {
            return String(format: "%.1fK", Double(volume) / 1_000)
        } else {
            return String(format: "%.0f", Double(volume))
        }
    }
}

@MainActor
class StockDetailViewModel: ObservableObject {
    @Published var historicalData: [StockQuote] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let service = MarketstackService()
    
    func fetchHistoricalData(for symbol: String) async {
        isLoading = true
        do {
            historicalData = try await service.fetchHistoricalData(for: symbol)
        } catch {
            self.error = error
        }
        isLoading = false
    }
} 
