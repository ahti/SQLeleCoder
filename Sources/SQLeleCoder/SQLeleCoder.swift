import Foundation
import SQLele

public enum SQLeleCoderError: Error {
    case notSupported(String)
    case unexpectedNull
    case multipleKeyedContainersRequested
    case integerOverflow
}

// This is used to get an arrya of query parameters into
// the fetch(...) statement. On it's own, this wouldn't work
// right, because types needing special treatment (e.g. Date)
// would not get it. Thus, StatementEncoder explicitly checks
// and unwraps AnyEncodable instances.
struct AnyEncodable: Encodable {
    let w: Encodable
    init(_ codable: Encodable) {
        w = codable
    }
    func encode(to encoder: Encoder) throws {
        try w.encode(to: encoder)
    }
}

extension Connection {
    public enum InsertError: Error {
        case noColumnsProvided
    }

    public enum ConflictResolution: String {
        case rollback = "ROLLBACK"
        case abort = "ABORT"
        case fail = "FAIL"
        case ignore = "IGNORE"
        case replace = "REPLACE"
    }

    public func insert<Seq: Sequence>(_ values: Seq, or conflictResolution: ConflictResolution? = nil, into table: String? = nil, userInfo: [CodingUserInfoKey: Any] = [:], inTransaction: Bool = true) throws where Seq.Element: Encodable {
        guard let first = values.first(where: { _ in true }) else {
            return
        }
        let qb = QueryBuilderEncoder(userInfo: userInfo)
        try first.encode(to: qb)
        let query = try qb.query(in: table ?? "\(Seq.Element.self)", conflictResolution: conflictResolution).unwrap(or: InsertError.noColumnsProvided)
        let s = try prepare(query)
        let run = {
            for v in values {
                try s.encode(v)
                _ = try s.step()
                s.reset()
            }
        }
        if inTransaction {
            try transaction {
                try run()
            }
        } else {
            try run()
        }
    }

    public func fetch<T: Decodable>(
        _ type: T.Type,
        from table: String? = nil,
        where whereClause: String? = nil,
        parameters: [Encodable]? = nil,
        orderBy orderClause: String? = nil,
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) throws -> [T] {
        var query = "SELECT * FROM \(table ?? "\(T.self)")"
        if let c = whereClause {
            query += " WHERE " + c
        }
        if let o = orderClause {
            query += " ORDER BY " + o
        }
        let s = try prepare(query)
        if let p = parameters {
            for (index, param) in zip(1..., p) {
                try s.bind(index, to: AnyEncodable(param))
            }
        }
        var res = [T]()
        while let row = try s.step() {
            res.append(try row.decode())
        }
        return res
    }
}

extension Statement {
    public enum ParameterPrefix: String {
        case at = "@"
        case dollar = "$"
        case colon = ":"
    }

    func encode(_ object: Encodable, prefix: ParameterPrefix = .colon, userInfo: [CodingUserInfoKey: Any] = [:]) throws {
        let encoder = StatementEncoder(statement: self, prefix: prefix, userInfo: userInfo)
        clearBindings()
        do {
            try object.encode(to: encoder)
        } catch let e {
            clearBindings()
            throw e
        }
    }


    public func bind<T: Encodable>(_ index: Int, to obj: T?, userInfo: [CodingUserInfoKey: Any] = [:]) throws {
        guard let obj = obj else {
            try bindNull(index)
            return
        }
        let encoder = StatementEncoder(statement: self, prefix: nil, userInfo: userInfo)
        try encoder.bindEncodable(obj, key: ParameterIndex(index))
    }

    public func bind<T: Encodable>(_ name: String, to obj: T?, userInfo: [CodingUserInfoKey: Any] = [:]) throws {
        guard let obj = obj else {
            try bindNull(name)
            return
        }
        let encoder = StatementEncoder(statement: self, prefix: nil, userInfo: userInfo)
        try encoder.bindEncodable(obj, key: ParameterName(name))
    }
}

extension Row {
    public func decode<T: Decodable>(userInfo: [CodingUserInfoKey: Any] = [:]) throws -> T {
        let c = RowDecoder(row: self, userInfo: userInfo)
        return try T(from: c)
    }

    public func column<T: Decodable>(_ index: Int, userInfo: [CodingUserInfoKey: Any] = [:]) throws -> T? {
        guard !columnIsNull(index) else { return nil }
        let c = RowDecoder(row: self, userInfo: userInfo)
        return try c.decode(key: ParameterIndex(index)) as T
    }

    public func column<T: Decodable>(_ name: String, userInfo: [CodingUserInfoKey: Any] = [:]) throws -> T? {
        guard try !columnIsNull(name) else { return nil }
        let c = RowDecoder(row: self, userInfo: userInfo)
        return try c.decode(key: ParameterName(name)) as T
    }
}
