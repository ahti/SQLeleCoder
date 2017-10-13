import Foundation
import SQLele

private func unwrap<T>(_ o: T?) throws -> T {
    return try o.unwrap(or: SQLeleCoderError.unexpectedNull)
}

private func unwrap<T>(_ o: Int64?) throws -> T where T: BinaryInteger {
    let i = try o.unwrap(or: SQLeleCoderError.unexpectedNull)
    return try T(exactly: i).unwrap(or: SQLeleCoderError.integerOverflow)
}

class RowDecoder: Decoder {
    init(row: Row, userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.row = row
        self.userInfo = userInfo
    }

    let row: Row
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any]

    class SingleContainer: SingleValueDecodingContainer {
        let r: Row
        let k: CodingKey
        weak var d: RowDecoder!
        init(row: Row, key: CodingKey, decoder: RowDecoder) {
            r = row
            k = key
            d = decoder
        }

        var n: String {
            return k.stringValue
        }

        var codingPath: [CodingKey] {
            return d.codingPath
        }

        func decodeNil() -> Bool { return try! r.columnIsNull(n) }
        func decode(_ type: Bool.Type) throws -> Bool     { return try unwrap(r.column(n)) as Int64 != 0 }
        func decode(_ type: Int.Type) throws -> Int       { return try unwrap(r.column(n)) }
        func decode(_ type: Int8.Type) throws -> Int8     { return try unwrap(r.column(n)) }
        func decode(_ type: Int16.Type) throws -> Int16   { return try unwrap(r.column(n)) }
        func decode(_ type: Int32.Type) throws -> Int32   { return try unwrap(r.column(n)) }
        func decode(_ type: Int64.Type) throws -> Int64   { return try unwrap(r.column(n)) }
        func decode(_ type: UInt.Type) throws -> UInt     { return try unwrap(r.column(n)) }
        func decode(_ type: UInt8.Type) throws -> UInt8   { return try unwrap(r.column(n)) }
        func decode(_ type: UInt16.Type) throws -> UInt16 { return try unwrap(r.column(n)) }
        func decode(_ type: UInt32.Type) throws -> UInt32 { return try unwrap(r.column(n)) }
        func decode(_ type: UInt64.Type) throws -> UInt64 { return try unwrap(r.column(n)) }
        func decode(_ type: Float.Type) throws -> Float   { return try Float(decode(Double.self)) }
        func decode(_ type: Double.Type) throws -> Double { return try unwrap(r.column(n)) }
        func decode(_ type: String.Type) throws -> String { return try unwrap(r.column(n)) }
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable { return try d._decode(key: k) }
    }

    class Container<KeyType: CodingKey>: KeyedDecodingContainerProtocol {
        var codingPath: [CodingKey] {
            return dec.codingPath
        }

        var allKeys: [KeyType] {
            return row.columnNames.flatMap { Key(stringValue: $0) }
        }

        func contains(_ key: KeyType) -> Bool {
            return row.columnNameMap[key.stringValue] != nil
        }

        func decodeNil(forKey key: KeyType) throws -> Bool { return try row.columnIsNull(key.stringValue) }
        func decode(_ type: Bool.Type, forKey key: KeyType) throws -> Bool     { return try unwrap(row.column(key.stringValue)) as Int64 != 0 }
        func decode(_ type: Int.Type, forKey key: KeyType) throws -> Int       { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: Int8.Type, forKey key: KeyType) throws -> Int8     { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: Int16.Type, forKey key: KeyType) throws -> Int16   { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: Int32.Type, forKey key: KeyType) throws -> Int32   { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: Int64.Type, forKey key: KeyType) throws -> Int64   { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: UInt.Type, forKey key: KeyType) throws -> UInt     { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: UInt8.Type, forKey key: KeyType) throws -> UInt8   { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: UInt16.Type, forKey key: KeyType) throws -> UInt16 { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: UInt32.Type, forKey key: KeyType) throws -> UInt32 { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: UInt64.Type, forKey key: KeyType) throws -> UInt64 { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: Float.Type, forKey key: KeyType) throws -> Float   { return try Float(decode(Double.self, forKey: key)) }
        func decode(_ type: Double.Type, forKey key: KeyType) throws -> Double { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: String.Type, forKey key: KeyType) throws -> String { return try unwrap(row.column(key.stringValue)) }

        func decode<T>(_ type: T.Type, forKey key: KeyType) throws -> T where T : Decodable {
            return try dec.decode(key: key)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: KeyType) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            throw SQLeleCoderError.notSupported(#function)
        }

        func nestedUnkeyedContainer(forKey key: KeyType) throws -> UnkeyedDecodingContainer {
            throw SQLeleCoderError.notSupported(#function)
        }

        func superDecoder() throws -> Decoder {
            throw SQLeleCoderError.notSupported(#function)
        }

        func superDecoder(forKey key: KeyType) throws -> Decoder {
            throw SQLeleCoderError.notSupported(#function)
        }

        typealias Key = KeyType

        init(row: Row, dec: RowDecoder) {
            self.row = row
            self.dec = dec
        }

        let row: Row
        weak var dec: RowDecoder!
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        switch codingPath.count {
        case 0: return KeyedDecodingContainer(Container(row: row, dec: self))
        case 1: throw InternalError.needsJsonCoding
        case _: fatalError()
        }
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard codingPath.count == 1 else { fatalError() }
        throw InternalError.needsJsonCoding
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        guard codingPath.count == 1 else { fatalError() }
        return SingleContainer(row: row, key: codingPath[0], decoder: self)
    }

    func decode<T: Decodable>(key: CodingKey) throws -> T {
        codingPath.append(key)
        defer {
            codingPath.removeLast()
        }
        return try _decode(key: key)
    }

    func _decode<T: Decodable>(key: CodingKey) throws -> T {
        let name = key.stringValue
        if T.self == Data.self {
            let d = try row.column(name) as Data?
            return try d.unwrap(or: SQLeleCoderError.unexpectedNull) as! T
        } else if T.self == Date.self {
            let d = try unwrap(row.column(name)) as Double
            return Date(timeIntervalSince1970: d) as! T
        } else if T.self == URL.self {
            let s = try unwrap(row.column(name)) as String
            return try URL(string: s).unwrap(or: DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid URL string"))) as! T
        }

        do {
            return try T(from: self)
        } catch InternalError.needsJsonCoding {
            let jsonString = try unwrap(row.column(name)) as String
            let data = try jsonString.data(using: .utf8).unwrap(or: DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Couldn't utf8-encode json string")))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try decoder.decode(T.self, from: data)
        }
    }
}
