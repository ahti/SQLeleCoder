import Foundation
import SQLele

private func wrapI<T>(_ o: T) throws -> Int64 where T: BinaryInteger {
    return try Int64(exactly: o).unwrap(or: SQLeleCoderError.integerOverflow)
}

class StatementEncoder: Encoder {
    class ThrowingEncoder: Encoder {
        init() {}
        var codingPath: [CodingKey] = []

        var userInfo: [CodingUserInfoKey : Any] = [:]

        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            return KeyedEncodingContainer(ThrowingKeyedContainer())
        }

        func unkeyedContainer() -> UnkeyedEncodingContainer {
            return ThrowingUnkeyedContainer()
        }

        func singleValueContainer() -> SingleValueEncodingContainer {
            return ThrowingSingleContainer()
        }


    }
    class ThrowingSingleContainer: SingleValueEncodingContainer {
        var codingPath: [CodingKey] = []
        func encodeNil() throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Bool) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int8) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int16) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int32) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int64) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt8) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt16) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt32) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt64) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Float) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Double) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: String) throws { throw InternalError.needsJsonCoding }
        func encode<T>(_ value: T) throws where T : Encodable { throw InternalError.needsJsonCoding }
    }

    class ThrowingUnkeyedContainer: UnkeyedEncodingContainer {
        var codingPath: [CodingKey] = []
        var count: Int = 0
        func encode(_ value: Int) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int8) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int16) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int32) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int64) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt8) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt16) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt32) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt64) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Float) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Double) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: String) throws { throw InternalError.needsJsonCoding }
        func encode<T>(_ value: T) throws where T : Encodable { throw InternalError.needsJsonCoding }
        func encode(_ value: Bool) throws { throw InternalError.needsJsonCoding }
        func encodeNil() throws { throw InternalError.needsJsonCoding }
        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey { return KeyedEncodingContainer(ThrowingKeyedContainer<NestedKey>())  }
        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer { return self }
        func superEncoder() -> Encoder { return ThrowingEncoder() }
    }

    class ThrowingKeyedContainer<KeyType: CodingKey>: KeyedEncodingContainerProtocol {
        init() {}
        typealias Key = KeyType
        var codingPath: [CodingKey] = []
        func encodeNil(forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Bool, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int8, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int16, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int32, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Int64, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt8, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt16, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt32, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: UInt64, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Float, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: Double, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode(_ value: String, forKey key: KeyType) throws { throw InternalError.needsJsonCoding }
        func encode<T>(_ value: T, forKey key: KeyType) throws where T : Encodable { throw InternalError.needsJsonCoding }
        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: KeyType) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            return KeyedEncodingContainer(ThrowingKeyedContainer<NestedKey>())
        }
        func nestedUnkeyedContainer(forKey key: KeyType) -> UnkeyedEncodingContainer {
            return ThrowingUnkeyedContainer()
        }
        func superEncoder() -> Encoder {
            fatalError()
        }

        func superEncoder(forKey key: KeyType) -> Encoder {
            fatalError()
        }
    }

    class SingleContainer: SingleValueEncodingContainer {
        let s: Statement
        let k: CodingKey
        weak var e: StatementEncoder!
        init(statement: Statement, key: CodingKey, encoder: StatementEncoder) {
            s = statement
            k = key
            e = encoder
        }

        var codingPath: [CodingKey] {
            return e.codingPath
        }

        func i() throws -> Int {
            return try e.indexForKey(k)
        }

        func encodeNil() throws { try s.bindNull(i()) }
        func encode(_ value: Bool) throws   { try s.bind(i(), to: Int64(value ? 1 : 0)) }
        func encode(_ value: Int) throws    { try s.bind(i(), to: wrapI(value)) }
        func encode(_ value: Int8) throws   { try s.bind(i(), to: wrapI(value)) }
        func encode(_ value: Int16) throws  { try s.bind(i(), to: wrapI(value)) }
        func encode(_ value: Int32) throws  { try s.bind(i(), to: wrapI(value)) }
        func encode(_ value: Int64) throws  { try s.bind(i(), to: value) }
        func encode(_ value: UInt) throws   { try s.bind(i(), to: wrapI(value)) }
        func encode(_ value: UInt8) throws  { try s.bind(i(), to: wrapI(value)) }
        func encode(_ value: UInt16) throws { try s.bind(i(), to: wrapI(value)) }
        func encode(_ value: UInt32) throws { try s.bind(i(), to: wrapI(value)) }
        func encode(_ value: UInt64) throws { try s.bind(i(), to: wrapI(value)) }
        func encode(_ value: Float) throws  { try s.bind(i(), to: Double(value)) }
        func encode(_ value: Double) throws { try s.bind(i(), to: value) }
        func encode(_ value: String) throws { try s.bind(i(), to: value) }
        func encode<T>(_ value: T) throws where T : Encodable { try e._bindEncodable(value, key: k) }
    }


    class Container<KeyType: CodingKey>: KeyedEncodingContainerProtocol {
        func encodeNil(forKey key: KeyType) throws { try s.bindNull(p(key)) }
        func encode(_ value: Bool, forKey key: KeyType) throws   { try s.bind(p(key), to: Int64(value ? 1 : 0)) }
        func encode(_ value: Int, forKey key: KeyType) throws    { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: Int8, forKey key: KeyType) throws   { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: Int16, forKey key: KeyType) throws  { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: Int32, forKey key: KeyType) throws  { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: Int64, forKey key: KeyType) throws  { try s.bind(p(key), to: value) }
        func encode(_ value: UInt, forKey key: KeyType) throws   { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: UInt8, forKey key: KeyType) throws  { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: UInt16, forKey key: KeyType) throws { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: UInt32, forKey key: KeyType) throws { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: UInt64, forKey key: KeyType) throws { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: Float, forKey key: KeyType) throws  { try s.bind(p(key), to: Double(value)) }
        func encode(_ value: Double, forKey key: KeyType) throws { try s.bind(p(key), to: value) }
        func encode(_ value: String, forKey key: KeyType) throws { try s.bind(p(key), to: value) }
        func encode<T>(_ value: T, forKey key: KeyType) throws where T : Encodable { try enc.bindEncodable(value, key: key) }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: KeyType) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            fatalError()
        }

        func nestedUnkeyedContainer(forKey key: KeyType) -> UnkeyedEncodingContainer {
            fatalError()
        }

        func superEncoder() -> Encoder {
            fatalError()
        }

        func superEncoder(forKey key: KeyType) -> Encoder {
            fatalError()
        }

        typealias Key = KeyType

        lazy var s: Statement = enc.statement
        lazy var prefix: String = enc.prefix

        func p(_ key: KeyType) -> String {
            return prefix + key.stringValue
        }

        weak var enc: StatementEncoder!
        init(enc: StatementEncoder) {
            self.enc = enc
        }
        var codingPath: [CodingKey] {
            return enc.codingPath
        }
    }

    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey : Any]

    var nestedNonSingleValueContainerRequested = false

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        switch codingPath.count {
        case 0: return KeyedEncodingContainer(Container(enc: self))
        case 1:
            nestedNonSingleValueContainerRequested = true
            return KeyedEncodingContainer(ThrowingKeyedContainer<Key>())
        case _: fatalError()
        }
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        guard codingPath.count == 1 else { fatalError() }
        nestedNonSingleValueContainerRequested = true
        return ThrowingUnkeyedContainer()
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        guard codingPath.count == 1 else { fatalError() }
        return SingleContainer(statement: statement, key: codingPath[0], encoder: self)
    }

    func bindEncodable<T: Encodable>(_ obj: T, key: CodingKey) throws {
        codingPath.append(key)
        defer {
            codingPath.removeLast()
        }
        try _bindEncodable(obj, key: key)
    }

    func indexForKey(_ key: CodingKey) throws -> Int {
        switch key {
        case let index as ParameterIndex: return index.intValue!
        case let other: return try statement.bindParameterIndex(prefix + other.stringValue)
        }
    }

    func _bindEncodable<T: Encodable>(_ value: T, key: CodingKey) throws {
        let index = try indexForKey(key)
        if let d = value as? Data {
            try statement.bind(index, to: d)
            return
        } else if let d = value as? Date {
            try statement.bind(index, to: d.timeIntervalSince1970)
            return
        } else if let u = value as? URL {
            // we need to special case url, because JSONEncoder does, too,
            // and encodes it into a single string, but won't allow top-
            // level fragments :(
            try statement.bind(index, to: u.absoluteString)
            return
        }

        defer {
            nestedNonSingleValueContainerRequested = false
        }

        var needsJsonCodingThrown = false
        do {
            try value.encode(to: self)
        } catch InternalError.needsJsonCoding {
            needsJsonCodingThrown = true
        }

        // for empty arrays/objects, no methods on the throwing containers
        // are called, thus the nestedNonSingleValueContainerRequested var
        if needsJsonCodingThrown || nestedNonSingleValueContainerRequested {
            let json = JSONEncoder()
            json.userInfo = userInfo
            json.dateEncodingStrategy = .secondsSince1970
            let data = try json.encode(value)
            let string = String(data: data, encoding: .utf8)!
            try statement.bind(index, to: string)
        }
    }

    let statement: Statement
    let prefix: String

    typealias ParameterPrefix = Statement.ParameterPrefix

    init(statement: Statement, prefix: ParameterPrefix?, userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.statement = statement
        self.prefix = prefix?.rawValue ?? ""
        self.userInfo = userInfo
    }
}
