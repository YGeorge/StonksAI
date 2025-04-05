import SwiftUI
import Charts

struct StockDetailView: View {
    let symbol: String
    @StateObject private var viewModel = StockDetailViewModel()
    @State private var showMA = false
    @State private var maPeriod = 10
    
    private let maPeriods = [5, 10, 20, 50]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let latestQuote = viewModel.historicalData.first {
                    QuoteInfoView(quote: latestQuote)
                }
                
                // MA toggle button and period selector
                VStack(spacing: 8) {
                    HStack {
                        Text("Indicators:")
                            .foregroundColor(AppTheme.textColor)
                        Spacer()
                        Button(action: {
                            showMA.toggle()
                        }) {
                            Text("MA")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(showMA ? AppTheme.positiveColor : AppTheme.backgroundColor)
                                .foregroundColor(showMA ? .white : AppTheme.textColor)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppTheme.textColor.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    
                    if showMA {
                        HStack {
                            Text("MA Period:")
                                .font(.caption)
                                .foregroundColor(AppTheme.textColor)
                            Spacer()
                            Picker("MA Period", selection: $maPeriod) {
                                ForEach(maPeriods, id: \.self) { period in
                                    Text("\(period)").tag(period)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 200)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                CandlestickChart(data: viewModel.historicalData, showMA: showMA, maPeriod: maPeriod)
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
