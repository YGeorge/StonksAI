import Testing
@testable import StonksAI

struct StockRowViewModelTests {
    
    // Test stock with price increase
    func makeStockWithIncrease() -> StockQuote {
        StockQuote(
            symbol: "AAPL",
            close: 150.0,
            date: "2024-03-08",
            high: 155.0,
            low: 145.0,
            open: 147.0,
            volume: 1000000
        )
    }
    
    // Test stock with price decrease
    func makeStockWithDecrease() -> StockQuote {
        StockQuote(
            symbol: "MSFT",
            close: 280.0,
            date: "2024-03-08",
            high: 290.0,
            low: 275.0,
            open: 285.0,
            volume: 2000000
        )
    }
    
    @Test("Basic properties are correctly passed through")
    func testBasicProperties() {
        let stock = makeStockWithIncrease()
        let viewModel = StockRowViewModel(stock: stock)
        
        #expect(viewModel.symbol == "AAPL")
        #expect(viewModel.closePrice == 150.0, "Close price should be 150.0")
        #expect(viewModel.openPrice == 147.0, "Open price should be 147.0")
        #expect(viewModel.highPrice == 155.0, "High price should be 155.0")
        #expect(viewModel.lowPrice == 145.0, "Low price should be 145.0")
    }
    
    @Test("Price change calculations are correct for increase")
    func testPriceChangeIncrease() {
        let stock = makeStockWithIncrease()
        let viewModel = StockRowViewModel(stock: stock)
        
        #expect(viewModel.priceChange == 3.0, "Price change should be 3.0")
        #expect(abs(viewModel.priceChangePercentage - 2.04) < 0.01, "Price change percentage should be approximately 2.04%")
        #expect(viewModel.isPriceUp, "Price should be marked as increased")
    }
    
    @Test("Price change calculations are correct for decrease")
    func testPriceChangeDecrease() {
        let stock = makeStockWithDecrease()
        let viewModel = StockRowViewModel(stock: stock)
        
        #expect(viewModel.priceChange == -5.0, "Price change should be -5.0")
        #expect(abs(viewModel.priceChangePercentage - (-1.75)) < 0.01, "Price change percentage should be approximately -1.75%")
        #expect(!viewModel.isPriceUp, "Price should be marked as decreased")
    }
    
    @Test("Price formatting is correct")
    func testPriceFormatting() {
        let stock = makeStockWithIncrease()
        let viewModel = StockRowViewModel(stock: stock)
        
        #expect(viewModel.closePriceFormatted == "150.00")
        #expect(viewModel.openPriceFormatted == "147.00")
        #expect(viewModel.highPriceFormatted == "155.00")
        #expect(viewModel.lowPriceFormatted == "145.00")
    }
    
    @Test("Change formatting is correct for increase")
    func testChangeFormattingIncrease() {
        let stock = makeStockWithIncrease()
        let viewModel = StockRowViewModel(stock: stock)
        
        #expect(viewModel.priceChangeFormatted == "+3.00")
        #expect(viewModel.priceChangePercentageFormatted == "+2.0%")
        #expect(viewModel.priceChangeText == "+3.00 (+2.0%)")
    }
    
    @Test("Change formatting is correct for decrease")
    func testChangeFormattingDecrease() {
        let stock = makeStockWithDecrease()
        let viewModel = StockRowViewModel(stock: stock)
        
        #expect(viewModel.priceChangeFormatted == "-5.00")
        #expect(viewModel.priceChangePercentageFormatted == "-1.8%")
        #expect(viewModel.priceChangeText == "-5.00 (-1.8%)")
    }
} 