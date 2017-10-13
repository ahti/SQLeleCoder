import Foundation

extension Optional {
    func unwrap(or e: Error) throws -> Wrapped {
        switch self {
        case .some(let w): return w
        case .none: throw e
        }
    }
}

enum InternalError: Error {
    case needsJsonCoding
}

struct ParameterIndex: CodingKey {
    let intValue: Int?
    init(_ int: Int) { intValue = int }
    init?(intValue: Int) { fatalError() }
    init?(stringValue: String) { fatalError() }
    var stringValue: String { fatalError() }
}

struct ParameterName: CodingKey {
    let stringValue: String
    init(_ str: String) { stringValue = str }
    init?(stringValue: String) { fatalError() }
    var intValue: Int? { fatalError() }
    init?(intValue: Int) { fatalError() }
}
