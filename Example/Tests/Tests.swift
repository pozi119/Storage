import Storage
import XCTest

class Tests: XCTestCase {
    lazy var table = Table(with: "valo")

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSet() {
        let k = DialogKey(dialog_id: 2, version: 2, record: "record".data(using: .utf8)!)
        let i = table.dialogKey.storage.keyValue(of: k)
        let r = table.dialogKey.set(i.0, value: k)
        let s = table.dialogKey.get(i.0)
        XCTAssert(r >= 0)
        XCTAssert(s == k)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
