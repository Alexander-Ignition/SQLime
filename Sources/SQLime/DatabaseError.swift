/// SQLite database error.
public struct DatabaseError: Error, Equatable, Hashable {
    /// Failed result code.
    public let code: Int32

    /// A short error description.
    public var message: String

    /// A complete sentence (or more) describing why the operation failed.
    public let reason: String

    /// A new database error.
    ///
    /// - Parameters:
    ///   - code: failed result code.
    ///   - message: A short error description.
    ///   - reason: A complete sentence (or more) describing why the operation failed.
    public init(code: Int32, message: String, reason: String) {
        self.code = code
        self.message = message
        self.reason = reason
    }
}
