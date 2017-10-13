import Foundation
import SQLele

public enum SQLeleCoderError: Error {
    case notSupported(String)
    case unexpectedNull
    case multipleKeyedContainersRequested
    case integerOverflow
}

extension Connection {
    public enum InsertError: Error {
        case noColumnsProvided
    }

    public func insert<Seq: Sequence>(_ values: Seq, into table: String? = nil, userInfo: [CodingUserInfoKey: Any] = [:]) throws where Seq.Element: Encodable {
        guard let first = values.first(where: { _ in true }) else {
            return
        }
        let qb = QueryBuilderEncoder(userInfo: userInfo)
        try first.encode(to: qb)
        let query = try qb.query(in: table ?? "\(Seq.Element.self)").unwrap(or: InsertError.noColumnsProvided)
        let s = try prepare(query)
        try transaction {
            for v in values {
                try s.encode(v)
                _ = try s.step()
                s.reset()
            }
        }
    }

    public func fetch<T: Decodable>(
        _ type: T.Type,
        from table: String? = nil,
        where whereClause: String? = nil,
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
