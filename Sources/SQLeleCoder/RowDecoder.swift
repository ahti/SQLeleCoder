import Foundation
import SQLele

class RowDecoder: Decoder {
    init(row: Row, userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.row = row
        self.userInfo = userInfo
    }

    let row: Row
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any]

    class SingleContainer<KeyType: CodingKey>: SingleValueDecodingContainer {
        let container: Container<KeyType>
        let key: KeyType
        init(container: Container<KeyType>, key: KeyType) {
            self.container = container
            self.key = key
        }

        var codingPath: [CodingKey] {
            return container.codingPath
        }

        func decodeNil() -> Bool { return try! container.decodeNil(forKey: key) }
        func decode(_ type: Bool.Type) throws -> Bool { return try container.decode(Bool.self, forKey: key) }
        func decode(_ type: Int.Type) throws -> Int { return try container.decode(Int.self, forKey: key) }
        func decode(_ type: Int8.Type) throws -> Int8 { return try container.decode(Int8.self, forKey: key) }
        func decode(_ type: Int16.Type) throws -> Int16 { return try container.decode(Int16.self, forKey: key) }
        func decode(_ type: Int32.Type) throws -> Int32 { return try container.decode(Int32.self, forKey: key) }
        func decode(_ type: Int64.Type) throws -> Int64 { return try container.decode(Int64.self, forKey: key) }
        func decode(_ type: UInt.Type) throws -> UInt { return try container.decode(UInt.self, forKey: key) }
        func decode(_ type: UInt8.Type) throws -> UInt8 { return try container.decode(UInt8.self, forKey: key) }
        func decode(_ type: UInt16.Type) throws -> UInt16 { return try container.decode(UInt16.self, forKey: key) }
        func decode(_ type: UInt32.Type) throws -> UInt32 { return try container.decode(UInt32.self, forKey: key) }
        func decode(_ type: UInt64.Type) throws -> UInt64 { return try container.decode(UInt64.self, forKey: key) }
        func decode(_ type: Float.Type) throws -> Float { return try container.decode(Float.self, forKey: key) }
        func decode(_ type: Double.Type) throws -> Double { return try container.decode(Double.self, forKey: key) }
        func decode(_ type: String.Type) throws -> String { return try container.decode(String.self, forKey: key) }
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable { return try container.decode(T.self, forKey: key) }
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

        func unwrap<T>(_ o: T?) throws -> T {
            return try o.unwrap(or: SQLeleCoderError.unexpectedNull)
        }

        func unwrap<T>(_ o: Int64?) throws -> T where T: BinaryInteger {
            let i = try o.unwrap(or: SQLeleCoderError.unexpectedNull)
            return try T(exactly: i).unwrap(or: SQLeleCoderError.integerOverflow)
        }

        func decodeNil(forKey key: KeyType) throws -> Bool { return try row.columnIsNull(key.stringValue) }
        func decode(_ type: Bool.Type, forKey key: KeyType) throws -> Bool { return try unwrap(row.column(key.stringValue)) as Int64 != 0 }
        func decode(_ type: Int.Type, forKey key: KeyType) throws -> Int { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: Int8.Type, forKey key: KeyType) throws -> Int8 { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: Int16.Type, forKey key: KeyType) throws -> Int16 { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: Int32.Type, forKey key: KeyType) throws -> Int32 { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: Int64.Type, forKey key: KeyType) throws -> Int64 { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: UInt.Type, forKey key: KeyType) throws -> UInt { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: UInt8.Type, forKey key: KeyType) throws -> UInt8 { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: UInt16.Type, forKey key: KeyType) throws -> UInt16 { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: UInt32.Type, forKey key: KeyType) throws -> UInt32 { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: UInt64.Type, forKey key: KeyType) throws -> UInt64 { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: Float.Type, forKey key: KeyType) throws -> Float { return try Float(decode(Double.self, forKey: key)) }
        func decode(_ type: Double.Type, forKey key: KeyType) throws -> Double { return try unwrap(row.column(key.stringValue)) }
        func decode(_ type: String.Type, forKey key: KeyType) throws -> String { return try unwrap(row.column(key.stringValue)) }

        func decode<T>(_ type: T.Type, forKey key: KeyType) throws -> T where T : Decodable {
            if type == Data.self {
                let d = try row.column(key.stringValue) as Data?
                return try d.unwrap(or: SQLeleCoderError.unexpectedNull) as! T
            } else if type == Date.self {
                let d = try decode(Double.self, forKey: key)
                return Date(timeIntervalSince1970: d) as! T
            }

            dec.codingPath.append(key)
            dec.singleValue = SingleContainer(container: self, key: key)
            defer {
                dec.singleValue = nil
                dec.codingPath.removeLast()
            }
            do {
                return try T(from: dec)
            } catch InternalError.needsJsonCoding {
                let jsonString = try decode(String.self, forKey: key)
                let data = try jsonString.data(using: .utf8).unwrap(or: SQLeleCoderError.unexpectedNull)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                return try decoder.decode(T.self, from: data)
            }
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

    var singleValue: SingleValueDecodingContainer? = nil

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
        guard codingPath.count == 1, let s = singleValue else { fatalError() }
        return s
    }
}
