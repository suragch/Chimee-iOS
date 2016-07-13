
import XCTest

class ChimeeUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testAeiouKeyboardKeys() {
        
        let app = XCUIApplication()
        app.scrollViews.otherElements.icons["Chimee"].tap()
        XCUIDevice.sharedDevice().orientation = .Portrait
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        let element25 = app.otherElements.containingType(.NavigationBar, identifier:"Chimee.MainView").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(2).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element
        let element = element25.childrenMatchingType(.Other).elementBoundByIndex(0)
        element.tap()
        
        let element2 = element25.childrenMatchingType(.Other).elementBoundByIndex(1)
        element2.tap()
        
        let element3 = element25.childrenMatchingType(.Other).elementBoundByIndex(2)
        element3.tap()
        
        let element4 = element25.childrenMatchingType(.Other).elementBoundByIndex(3)
        element4.tap()
        
        let element5 = element25.childrenMatchingType(.Other).elementBoundByIndex(4)
        element5.tap()
        
        let element6 = element25.childrenMatchingType(.Other).elementBoundByIndex(5)
        element6.tap()
        
        let element7 = element25.childrenMatchingType(.Other).elementBoundByIndex(6)
        element7.tap()
        
        let element8 = element25.childrenMatchingType(.Other).elementBoundByIndex(7)
        element8.tap()
        
        let element9 = element25.childrenMatchingType(.Other).elementBoundByIndex(8)
        element9.tap()
        
        let element10 = element25.childrenMatchingType(.Other).elementBoundByIndex(9)
        element10.tap()
        
        let element11 = element25.childrenMatchingType(.Other).elementBoundByIndex(10)
        element11.tap()
        
        let element12 = element25.childrenMatchingType(.Other).elementBoundByIndex(11)
        element12.tap()
        
        let element13 = element25.childrenMatchingType(.Other).elementBoundByIndex(12)
        element13.tap()
        
        let element14 = element25.childrenMatchingType(.Other).elementBoundByIndex(13)
        element14.tap()
        
        let element15 = element25.childrenMatchingType(.Other).elementBoundByIndex(14)
        element15.tap()
        
        let element16 = element25.childrenMatchingType(.Other).elementBoundByIndex(15)
        element16.tap()
        
        let element17 = element25.childrenMatchingType(.Other).elementBoundByIndex(16)
        element17.tap()
        
        let element18 = element25.childrenMatchingType(.Other).elementBoundByIndex(17)
        element18.tap()
        
        let element19 = element25.childrenMatchingType(.Other).elementBoundByIndex(18)
        element19.tap()
        
        let element20 = element25.childrenMatchingType(.Other).elementBoundByIndex(19)
        element20.tap()
        
        let element21 = element25.childrenMatchingType(.Other).elementBoundByIndex(20)
        element21.tap()
        
        let element22 = element25.childrenMatchingType(.Other).elementBoundByIndex(21)
        element22.tap()
        
        let element23 = element25.childrenMatchingType(.Other).elementBoundByIndex(22)
        element23.tap()
        
        let element24 = element25.childrenMatchingType(.Other).elementBoundByIndex(23)
        element24.tap()
        element25.childrenMatchingType(.Other).elementBoundByIndex(24).tap()
        element25.childrenMatchingType(.Other).elementBoundByIndex(25).tap()
        
        let element26 = element25.childrenMatchingType(.Other).elementBoundByIndex(26)
        element26.tap()
        
        let element27 = element25.childrenMatchingType(.Other).elementBoundByIndex(27)
        element27.tap()
        element.tap()
        element2.tap()
        element3.tap()
        element4.tap()
        element5.tap()
        element6.tap()
        element7.tap()
        element8.tap()
        element9.tap()
        element10.tap()
        element11.tap()
        element12.tap()
        element13.tap()
        element14.tap()
        element15.tap()
        element16.tap()
        element17.tap()
        element18.tap()
        element19.tap()
        element20.tap()
        element21.tap()
        element22.tap()
        element23.tap()
        element24.tap()
        element25.childrenMatchingType(.Other).elementBoundByIndex(29).tap()
        element25.childrenMatchingType(.Other).elementBoundByIndex(30).tap()
        element25.childrenMatchingType(.Other).elementBoundByIndex(28).tap()
        element26.tap()
        element27.tap()

        
    }
    
}
