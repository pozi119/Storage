import Storage
import XCTest

class Tests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSet() {
        let user = User(id: 0, name: "li 0", photo: "li-0", remark: "li#0")
        let r = Table.user.set("0", value: user)
        XCTAssert(r >= 0)
    }

    func testMultSet() {
        var users: [String: User] = [:]
        for i in 0 ..< 100 {
            let user = User(id: Int64(i), name: "li \(i)", photo: "li-\(i)", remark: "li#\(i)")
            users["\(i)"] = user
        }
        let r = Table.user.multiSet(users)
        XCTAssert(r.count >= 0)
    }

    func testGet() {
        let user = User(id: 0, name: "li 0", photo: "li-0", remark: "li#0")
        let r = Table.user.get("0")
        XCTAssert(r == user)
    }

    func testMultiGet() {
        let r = Table.user.multiGet(["0", "1", "9", "22"])
        XCTAssert(r.count > 0)
    }

    func testScan() {
        let r1 = Table.user.scan(lower: "10", limit: 20, bounds: .none, desc: false)
        let r2 = Table.user.scan(upper: "30", limit: 20, bounds: .none, desc: true)
        let r3 = Table.user.scan(lower: "10", upper: "30", bounds: .all, desc: false)
        let r4 = Table.user.scan(lower: "10", upper: "30", bounds: .none, desc: true)
        print(r1)
        print(r2)
        print(r3)
        print(r4)
    }

    func testRound() {
        let r1 = Table.user.round("30", lower: 10, upper: 10, desc: false)
        let r2 = Table.user.round(nil, lower: 10, upper: 10, desc: false)
        let r3 = Table.user.round("95", lower: 10, upper: 10, desc: true)
        let r4 = Table.user.round("30", lower: 10, upper: 10, desc: true)
        print(r1)
        print(r2)
        print(r3)
        print(r4)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
