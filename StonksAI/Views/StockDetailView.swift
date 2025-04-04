import SwiftUI
import Charts

struct StockDetailView: View {
    let symbol: String
    @StateObject private var viewModel = StockDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let latestQuote = viewModel.historicalData.first {
                    QuoteInfoView(quote: latestQuote)
                }
                
                Chart(viewModel.historicalData) { quote in
                    LineMark(
                        x: .value("Date", quote.date),
                        y: .value("Price", quote.close)
                    )
                    .foregroundStyle(AppTheme.textColor)
                }
                .frame(height: 300)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { value in
                        AxisGridLine()
                            .foregroundStyle(AppTheme.textColor.opacity(0.3))
                        AxisValueLabel()
                            .foregroundStyle(AppTheme.textColor)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(AppTheme.textColor.opacity(0.3))
                        AxisValueLabel()
                            .foregroundStyle(AppTheme.textColor)
                    }
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
                        Text(volume.formatted())
                            .foregroundColor(AppTheme.textColor)
                    }
                }
            }
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
