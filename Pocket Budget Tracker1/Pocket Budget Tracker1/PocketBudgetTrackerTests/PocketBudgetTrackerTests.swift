import XCTest
@testable import PocketBudgetTracker

final class PocketBudgetTrackerTests: XCTestCase {
    
    var viewModel: DashboardViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = DashboardViewModel()
        
        // Pre-load mock transactions
        viewModel.transactions = [
            Transaction(title: "Salary", amount: 50000, category: "Income", type: "Income", date: Date()),
            Transaction(title: "Food", amount: 5000, category: "Food", type: "Expense", date: Date()),
            Transaction(title: "Transport", amount: 1500, category: "Transport", type: "Expense", date: Date())
        ]
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // Test total income
    func testTotalIncome() {
        let income = viewModel.totalIncome
        XCTAssertEqual(income, 50000, "Total income calculation failed")
    }
    
    // Test total expense
    func testTotalExpense() {
        let expense = viewModel.totalExpense
        XCTAssertEqual(expense, 6500, "Total expense calculation failed")
    }
    
    // Test balance calculation
    func testBalance() {
        let balance = viewModel.balance
        XCTAssertEqual(balance, 43500, "Balance calculation failed")
    }
    
    // Test ML prediction return value
    func testPredictionReturnsValue() {
        let prediction = viewModel.predictNextMonthExpense()
        XCTAssertNotNil(prediction, "ML Prediction is nil")
    }
}
