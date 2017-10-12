import Foundation
import SQLele

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

    class SingleContainer<KeyType: CodingKey>: SingleValueEncodingContainer {
        let container: Container<KeyType>
        let key: KeyType
        init(container: Container<KeyType>, key: KeyType) {
            self.container = container
            self.key = key
        }

        var codingPath: [CodingKey] {
            return container.codingPath
        }

        func encodeNil() throws { try container.encodeNil(forKey: key) }
        func encode(_ value: Bool) throws { try container.encode(value, forKey: key) }
        func encode(_ value: Int) throws { try container.encode(value, forKey: key) }
        func encode(_ value: Int8) throws { try container.encode(value, forKey: key) }
        func encode(_ value: Int16) throws { try container.encode(value, forKey: key) }
        func encode(_ value: Int32) throws { try container.encode(value, forKey: key) }
        func encode(_ value: Int64) throws { try container.encode(value, forKey: key) }
        func encode(_ value: UInt) throws { try container.encode(value, forKey: key) }
        func encode(_ value: UInt8) throws { try container.encode(value, forKey: key) }
        func encode(_ value: UInt16) throws { try container.encode(value, forKey: key) }
        func encode(_ value: UInt32) throws { try container.encode(value, forKey: key) }
        func encode(_ value: UInt64) throws { try container.encode(value, forKey: key) }
        func encode(_ value: Float) throws { try container.encode(value, forKey: key) }
        func encode(_ value: Double) throws { try container.encode(value, forKey: key) }
        func encode(_ value: String) throws { try container.encode(value, forKey: key) }
        func encode<T>(_ value: T) throws where T : Encodable { try container.encode(value, forKey: key) }
    }


    class Container<KeyType: CodingKey>: KeyedEncodingContainerProtocol {
        func wrapI<T>(_ o: T) throws -> Int64 where T: BinaryInteger {
            return try Int64(exactly: o).unwrap(or: SQLeleCoderError.integerOverflow)
        }

        func encodeNil(forKey key: KeyType) throws { try s.bindNull(p(key)) }
        func encode(_ value: Bool, forKey key: KeyType) throws { try s.bind(p(key), to: Int64(value ? 1 : 0)) }
        func encode(_ value: Int, forKey key: KeyType) throws { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: Int8, forKey key: KeyType) throws { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: Int16, forKey key: KeyType) throws { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: Int32, forKey key: KeyType) throws { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: Int64, forKey key: KeyType) throws { try s.bind(p(key), to: value) }
        func encode(_ value: UInt, forKey key: KeyType) throws { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: UInt8, forKey key: KeyType) throws { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: UInt16, forKey key: KeyType) throws { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: UInt32, forKey key: KeyType) throws { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: UInt64, forKey key: KeyType) throws { try s.bind(p(key), to: wrapI(value)) }
        func encode(_ value: Float, forKey key: KeyType) throws { try s.bind(p(key), to: Double(value)) }
        func encode(_ value: Double, forKey key: KeyType) throws { try s.bind(p(key), to: value) }
        func encode(_ value: String, forKey key: KeyType) throws { try s.bind(p(key), to: value) }

        func encode<T>(_ value: T, forKey key: KeyType) throws where T : Encodable {
            if let d = value as? Data {
                try s.bind(p(key), to: d)
                return
            } else if let d = value as? Date {
                try encode(d.timeIntervalSince1970, forKey: key)
                return
            }

            enc.codingPath.append(key)
            enc.singleValue = SingleContainer(container: self, key: key)
            defer {
                enc.codingPath.removeLast()
                enc.singleValue = nil
                enc.nestedNonSingleValueContainerRequested = false
            }

            var needsJsonCodingThrown = false
            do {
                try value.encode(to: enc)
            } catch InternalError.needsJsonCoding {
                needsJsonCodingThrown = true
            }
            if needsJsonCodingThrown || enc.nestedNonSingleValueContainerRequested {
                // for empty arrays/objects, no methods on the throwing containers
                // are called, this the nestedNonSingleValueContainerRequested var

                let json = JSONEncoder()
                json.dateEncodingStrategy = .secondsSince1970
                let data = try json.encode(value)
                let string = String(data: data, encoding: .utf8)!
                try encode(string, forKey: key)
            }
        }

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
        lazy var prefix: ParameterPrefix = enc.prefix

        func p(_ key: KeyType) -> String {
            return prefix.rawValue + key.stringValue
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

    var singleValue: SingleValueEncodingContainer? = nil

    func singleValueContainer() -> SingleValueEncodingContainer {
        guard codingPath.count == 1, let s = singleValue else { fatalError() }
        return s
    }

    let statement: Statement
    let prefix: ParameterPrefix

    typealias ParameterPrefix = Statement.ParameterPrefix

    init(statement: Statement, prefix: ParameterPrefix, userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.statement = statement
        self.prefix = prefix
        self.userInfo = userInfo
    }
}
