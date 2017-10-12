import Foundation
import SQLele

class QueryBuilderEncoder: Encoder {
    class Container<KeyType: CodingKey>: KeyedEncodingContainerProtocol {
        var codingPath: [CodingKey] = []

        func encodeNil(forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: Bool, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: Int, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: Int8, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: Int16, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: Int32, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: Int64, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: UInt, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: UInt8, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: UInt16, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: UInt32, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: UInt64, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: Float, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: Double, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode(_ value: String, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encode<T>(_ value: T, forKey key: KeyType) throws where T : Encodable { enc.columns.insert(key.stringValue) }

        func encodeIfPresent(_ value: Bool?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent(_ value: Int?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent(_ value: Int8?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent(_ value: Int16?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent(_ value: Int32?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent(_ value: Int64?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent(_ value: UInt?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent(_ value: UInt8?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent(_ value: UInt16?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent(_ value: UInt32?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent(_ value: UInt64?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent(_ value: Float?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent(_ value: Double?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent(_ value: String?, forKey key: KeyType) throws { enc.columns.insert(key.stringValue) }
        func encodeIfPresent<T>(_ value: T?, forKey key: KeyType) throws where T : Encodable { enc.columns.insert(key.stringValue) }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: KeyType) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey { fatalError() }
        func nestedUnkeyedContainer(forKey key: KeyType) -> UnkeyedEncodingContainer { fatalError() }
        func superEncoder() -> Encoder { fatalError() }
        func superEncoder(forKey key: KeyType) -> Encoder { fatalError() }

        typealias Key = KeyType

        weak var enc: QueryBuilderEncoder!

        init(enc: QueryBuilderEncoder) {
            self.enc = enc
        }
    }

    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey: Any]

    var columns: Set<String> = []

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(Container(enc: self))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer { fatalError() }
    func singleValueContainer() -> SingleValueEncodingContainer { fatalError() }

    init(userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.userInfo = userInfo
    }

    func query(in table: String) -> String? {
        guard !columns.isEmpty else { return nil }
        func vars(_ prefix: String? = nil) -> String {
            let names: [String]
            if let p = prefix {
                names = columns.map { p + $0 }
            } else {
                names = Array(columns)
            }
            return names.joined(separator: ", ")
        }
        return "INSERT INTO \(table) (\(vars())) VALUES (\(vars(":")))"
    }
}
