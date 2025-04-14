import SwiftUI

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