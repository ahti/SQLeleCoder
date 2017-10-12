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
