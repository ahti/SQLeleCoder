import XCTest
import SQLele
@testable import SQLeleCoder

struct Test: Codable {
    let id: UUID
    let name: String?
    let age: Int
    let something: Date?
    let arrr: [Int]
    let nested: Nested?
}

struct Nested: Codable {
    let id: UUID
    let some: Date
    let boo: [String]
}

func peek<T>(_ t: T) -> T {
    print(t)
    return t
}

func datesEqual(_ a: Date?, _ b: Date?) -> Bool {
    switch (a, b) {
    case (.none, .none):
        return true
    case let (.some(l), .some(r)):
        return abs(l.timeIntervalSince(r)) < 0.001
    default:
        return false
    }
}

extension Test: Equatable {
    static func ==(lhs: Test, rhs: Test) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.age == rhs.age
            && datesEqual(lhs.something, rhs.something)
            && lhs.arrr == rhs.arrr
            && lhs.nested == rhs.nested
    }
}

extension Nested: Equatable {
    static func ==(lhs: Nested, rhs: Nested) -> Bool {
        return lhs.id == rhs.id
            && datesEqual(lhs.some, rhs.some)
            && lhs.boo == rhs.boo
    }
}

struct NilError: Error {}

func assertNoThrow<T>(_ c: @autoclosure () throws -> T, file: StaticString = #file, line: UInt = #line) -> T {
    do {
        return try c()
    } catch let e {
        XCTFail("caught error \(e)", file: file, line: line)
        fatalError()
    }
}

enum CodableEnum: String, Codable {
    case onOneHand
    case onTheOther
    case wellActually
}

struct DataAndDate: Codable {
    let data: Data
    let date: Date
}

class SQLeleCoderTests: XCTestCase {
    let db = try! Connection()

    override func setUp() {
        super.setUp()
        try! db.run("create table Test (id text primary key, name text, age numeric not null, something real, arrr text not null, nested text)")
        try! db.run("create table DataAndDate (data not null, date not null)")
        try! db.run("create table Stuff (a, b, c, d)")
    }

    override func tearDown() {
        super.tearDown()
        try! db.run("drop table Test")
    }

    func testDataAndDate() {
        let d = DataAndDate(data: Data(bytes: [9, 9, 9, 9]), date: Date())
        assertNoThrow(try db.insert([d]))
        let row = try! db.prepare("select * from DataAndDate").step()!
        XCTAssertEqual(row.storageClass(at: 0), .blob)
        XCTAssertEqual(row.storageClass(at: 1), .real)
        XCTAssertEqual(try row.column(0) as Data?, d.data)
        XCTAssertEqual(try row.column(1) as Double?, d.date.timeIntervalSince1970)
    }

    func testQueryPerformance() {
        let manyValues = (0..<10_000).map {
            Test(id: UUID(), name: "foo \($0)", age: $0, something: nil, arrr: [], nested: Nested(id: UUID(), some: Date(), boo: ["123"]))
        }
        let queryBuilder = QueryBuilderEncoder()
        measure {
            for v in manyValues {
                try! v.encode(to: queryBuilder)
            }
        }
    }

    func testEncodePerformance() {
        let manyValues = (0..<1_000).map {
            Test(id: UUID(), name: "foo \($0)", age: $0, something: Date(), arrr: [], nested: nil)
        }
        let queryBuilder = QueryBuilderEncoder()
        for v in manyValues {
            try! v.encode(to: queryBuilder)
        }
        let query = queryBuilder.query(in: "Test")!
        let s = try! db.prepare(query)

        measure {
            for v in manyValues {
                try! s.encode(v)
            }
        }
    }

    func testInsertPerformance() {
        let manyValues = (0..<1_000).map {
            Test(id: UUID(), name: "foo \($0)", age: $0, something: nil, arrr: [], nested: Nested(id: UUID(), some: Date(), boo: ["123"]))
        }
        let queryBuilder = QueryBuilderEncoder()
        for v in manyValues {
            try! v.encode(to: queryBuilder)
        }
        let query = queryBuilder.query(in: "Test")!
        let s = try! db.prepare(query)

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            startMeasuring()
            try! db.transaction {
                for v in manyValues {
                    try! s.encode(v)
                    _ = try! s.step()
                    s.reset()
                }
            }
            stopMeasuring()
            try! db.run("delete from Test")
        }
    }

    func testQueryBuilding() {
        let values = [
            Test(id: UUID(), name: "something", age: 1, something: nil, arrr: [], nested: nil),
            Test(id: UUID(), name: nil, age: 2, something: Date(), arrr: [1, 2, 3], nested: Nested(id: UUID(), some: Date(), boo: [])),
            Test(id: UUID(), name: nil, age: 3, something: nil, arrr: [], nested: nil)
        ]
        assertNoThrow(try db.insert(values))
        let res = assertNoThrow(try db.fetch(Test.self, orderBy: "age"))
        XCTAssertEqual(values, res)
    }

    func testRoundtrip() {
        let s = assertNoThrow(try db.prepare("insert into Test (id, name, age, something, arrr, nested) values (:id, :name, :age, :something, :arrr, :nested)"))
        let val = Test(id: UUID(), name: "works?", age: -32, something: Date() - 2000, arrr: [42, 12, 2], nested: Nested(id: UUID(), some: Date() + 10, boo: ["hallo na"]))
        assertNoThrow(try s.encode(val))
        _ = assertNoThrow(try s.step())

        let f = assertNoThrow(try db.prepare("select * from Test"))
        let r = assertNoThrow(try f.step().unwrap(or: NilError()))
        let fetched = assertNoThrow(try r.decode()) as Test
        XCTAssertEqual(val, fetched)
    }

    func testEncode() throws {
        let s = assertNoThrow(try db.prepare("insert into Test (id, name, age, something, arrr, nested) values (:id, :name, :age, :something, :arrr, :nested)"))
        let val = Test(id: UUID(), name: "pls", age: 69, something: Date(), arrr: [42, 12, 2], nested: Nested(id: UUID(), some: Date() + 10, boo: ["hallo na"]))
        assertNoThrow(try s.encode(val))
    }

    func testDecode() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //\"\"2017-10-11T01:29:17Z\"\"
        XCTAssertNoThrow(try db.run("insert into Test values (\"0ea71cf0-28da-49b7-9fd6-66bc4dbad20c\", null, 32, 0, \"[1,2,3]\", \"{\"\"id\"\":\"\"871E1E61-BEB4-47EB-81D8-291500617D7B\"\",\"\"some\"\":123,\"\"boo\"\":[\"\"String\"\"]}\")"))
        XCTAssertNoThrow(try db.run("insert into Test values (\"a23e03ba-30e0-486a-aed2-31dd2500148c\", \"wusa\", 32, null, \"[]\", null)"))

        let stmt = assertNoThrow(try db.prepare("select * from Test"))
        while let row = assertNoThrow(try stmt.step()) {
            _ = assertNoThrow(try row.decode() as Test)
        }
    }

    func testBindAndFetchEncodables() throws {
        let i = assertNoThrow(try db.prepare("insert into Stuff values (?, :b, :c, :d)"))
        assertNoThrow(try i.bind(1, to: Date(timeIntervalSince1970: 16)))
        assertNoThrow(try i.bind(":b", to: URL(string: "https://github.com/ahti/SQLeleCoder")!))
        assertNoThrow(try i.bind(":c", to: DataAndDate(data: Data(), date: Date(timeIntervalSince1970: 42))))
        assertNoThrow(try i.bind(":d", to: CodableEnum.wellActually))
        _ = assertNoThrow(try i.step())

        let f = assertNoThrow(try db.prepare("select * from Stuff"))
        let r = assertNoThrow(try f.step())!
        XCTAssertEqual(try r.column("a"), Date(timeIntervalSince1970: 16))
        XCTAssertEqual(try r.column("b"), URL(string: "https://github.com/ahti/SQLeleCoder")!)
        let c = assertNoThrow(try r.column("c")!) as DataAndDate
        XCTAssertEqual(c.data, Data())
        XCTAssertEqual(c.date, Date(timeIntervalSince1970: 42))
        XCTAssertEqual(try r.column("d"), CodableEnum.wellActually)
    }

    static var allTests = [
        ("testDataAndDate", testDataAndDate),
        ("testQueryPerformance", testQueryPerformance),
        ("testEncodePerformance", testEncodePerformance),
        ("testInsertPerformance", testInsertPerformance),
        ("testQueryBuilding", testQueryBuilding),
        ("testRoundtrip", testRoundtrip),
        ("testEncode", testEncode),
        ("testDecode", testDecode),
        ("testBindAndFetchEncodables", testBindAndFetchEncodables),
    ]
}
