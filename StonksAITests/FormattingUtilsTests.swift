import Testing
@testable import StonksAI

struct FormattingUtilsTests {
    
    @Test("Format billions correctly")
    func testFormatVolume_Billions() {
        #expect(FormattingUtils.formatVolume(1_500_000_000) == "1.5B", "1.5B should be formatted as 1.5B")
        #expect(FormattingUtils.formatVolume(2_000_000_000) == "2.0B", "2.0B should be formatted as 2.0B")
        #expect(FormattingUtils.formatVolume(999_999_999) == "1.0B", "999,999,999 should be rounded to 1.0B")
    }
    
    @Test("Format millions correctly")
    func testFormatVolume_Millions() {
        #expect(FormattingUtils.formatVolume(1_500_000) == "1.5M", "1.5M should be formatted as 1.5M")
        #expect(FormattingUtils.formatVolume(2_000_000) == "2.0M", "2.0M should be formatted as 2.0M")
        #expect(FormattingUtils.formatVolume(999_999) == "1.0M", "999,999 should be rounded to 1.0M")
    }
    
    @Test("Format thousands correctly")
    func testFormatVolume_Thousands() {
        #expect(FormattingUtils.formatVolume(1_500) == "1.5K", "1.5K should be formatted as 1.5K")
        #expect(FormattingUtils.formatVolume(2_000) == "2.0K", "2.0K should be formatted as 2.0K")
        #expect(FormattingUtils.formatVolume(999) == "1.0K", "999 should be rounded to 1.0K")
    }
    
    @Test("Format small numbers correctly")
    func testFormatVolume_SmallNumbers() {
        #expect(FormattingUtils.formatVolume(500) == "500", "500 should be formatted as 500")
        #expect(FormattingUtils.formatVolume(1) == "1", "1 should be formatted as 1")
        #expect(FormattingUtils.formatVolume(0) == "0", "0 should be formatted as 0")
    }
    
    @Test("Handle nil volume correctly")
    func testFormatVolume_Nil() {
        #expect(FormattingUtils.formatVolume(nil) == "N/A", "Nil volume should return N/A")
    }
    
    @Test("Handle edge cases correctly")
    func testFormatVolume_EdgeCases() {
        #expect(FormattingUtils.formatVolume(999_999_999_999) == "1000.0B", "999,999,999,999 should be formatted as 1000.0B")
        #expect(FormattingUtils.formatVolume(999_999_999) == "1.0B", "999,999,999 should be rounded to 1.0B")
        #expect(FormattingUtils.formatVolume(999_999) == "1.0M", "999,999 should be rounded to 1.0M")
        #expect(FormattingUtils.formatVolume(999) == "1.0K", "999 should be rounded to 1.0K")
    }
} 
