# SQLeleCoder

SQLeleCoder contains extensions to SQLele that enable you to serialize/
deserialize Codable types into/from your SQLite database with no extra work.

Nested Codable types (that don't encode into a single-value container) are
supported by encoding them into JSON strings.

## Usage

```swift
struct Person: Codable {
    let name: String
}
struct Task: Codable {
    let id: UUID
    let text: String
    let assignedTo: Person?
    let due: Date?
}

let db: Connection = ...
let tasks = [
    Task(id: UUID(), text: "Add docs", assignedTo: Person(name: "Lukas"), due: Date() + 3600),
    Task(id: UUID(), text: "Enjoy", assignedTo: Person(name: "You"), due: nil),
]

try db.insert(tasks)

let fetched = try db.fetch(Task.self, orderBy: "text")

assert(tasks == fetched)
```

## Caveats

Codable types using nested containers or super containers are not currently
supported.

When using `insert(...)`, the method will encode the first value to an encoder
saving the accessed keys and building the insert query. This means that types
need to call one of the encode methods for all possible columns, regardless of
data. The Codable implementation derived by Swift does this for you.

SQLite integers are 64 bit signed integers. The implementation allows encoding
64 bit unsigned integers, but will throw an error if they overflow. Similarly,
decoding a value that does not fit in the requested integer type will throw an
error.
