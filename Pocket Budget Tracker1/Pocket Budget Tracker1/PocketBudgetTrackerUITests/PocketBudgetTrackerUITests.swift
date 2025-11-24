import XCTest

final class PocketBudgetTrackerUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    // Test Add Transaction Flow
    func testAddTransaction() {
        app.tabBars.buttons["Add"].tap()
        
        app.textFields["Title"].tap()
        app.textFields["Title"].typeText("Lunch")
        
        app.textFields["Amount"].tap()
        app.textFields["Amount"].typeText("350")
        
        app.buttons["Category"].tap()
        app.buttons["Food"].tap()
        
        app.buttons["Expense"].tap()
        app.buttons["Save"].tap()
        
        XCTAssertTrue(app.staticTexts["Lunch"].exists, "Transaction was not added successfully")
    }
    
    // Test Edit Transaction Flow
    func testEditTransaction() {
        let firstItem = app.tables.cells.element(boundBy: 0)
        firstItem.tap()
        
        app.textFields["Title"].tap()
        app.textFields["Title"].clearAndEnterText(text: "Lunch Updated")
        
        app.buttons["Save"].tap()
        
        XCTAssertTrue(app.staticTexts["Lunch Updated"].exists,
                      "Transaction was not edited successfully")
    }

    // Test Delete Transaction Flow
    func testDeleteTransaction() {
        let table = app.tables
        let firstCell = table.cells.element(boundBy: 0)
        
        if firstCell.exists {
            firstCell.swipeLeft()
            firstCell.buttons["Delete"].tap()
        }
        
        XCTAssertFalse(firstCell.exists, "Transaction was not deleted successfully")
    }
}

extension XCUIElement {
    func clearAndEnterText(text: String) {
        guard let string = self.value as? String else { return }
        self.tap()
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: string.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}
