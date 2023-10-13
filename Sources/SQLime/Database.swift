import SQLite3

/// SQLite database.
public final class Database {
    /// Execution callback type.
    ///
    /// - SeeAlso: `Database.execute(_:handler:)`.
    public typealias ExecutionHandler = (_ row: [String: String]) -> Void

    public struct OpenOptions: OptionSet {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static var readonly: OpenOptions { .init(SQLITE_OPEN_READONLY) }
        public static var readwrite: OpenOptions { .init(SQLITE_OPEN_READWRITE) }
        public static var create: OpenOptions { .init(SQLITE_OPEN_CREATE) }
        public static var uri: OpenOptions { .init(SQLITE_OPEN_URI) }
        public static var memory: OpenOptions { .init(SQLITE_OPEN_MEMORY) }
        public static var noMutex: OpenOptions { .init(SQLITE_OPEN_NOMUTEX) }
        public static var fullMutex: OpenOptions { .init(SQLITE_OPEN_FULLMUTEX) }
        public static var sharedCache: OpenOptions { .init(SQLITE_OPEN_SHAREDCACHE) }
        public static var privateCache: OpenOptions { .init(SQLITE_OPEN_PRIVATECACHE) }
    }

    /// SQLite db handle.
    public private(set) var db: OpaquePointer!
    
    public private(set) var isOpen = true

    /// Absolute path to database file.
    public var path: String {
        String(cString: sqlite3_db_filename(db, nil))
    }

    /// Determine if a database is read-only.
    ///
    /// - SeeAlso: `OpenOptions.readonly`.
    public var isReadonly: Bool {
        sqlite3_db_readonly(db, nil) == 1
    }

    /// Opening a new database connection.
    ///
    /// - Parameters:
    ///   - path: Relative or absolute path to the database file.
    ///   - options: Database open options.
    /// - Returns: A new database connection.
    /// - Throws: `DatabaseError`.
    public static func open(at path: String, options: OpenOptions = []) throws -> Database {
        let database = Database()

        let code = sqlite3_open_v2(path, &database.db, options.rawValue, nil)
        try database._check(code)

        return database
    }

    /// Use `Database.open(at:options:)`.
    private init() {}

    deinit {
        close()
    }

    public func close() {
        guard isOpen else {
            return
        }
        isOpen = false
        sqlite3_close_v2(db)
    }

    /// Run multiple statements of SQL.
    ///
    /// - Parameter sql: statements.
    /// - Throws: `DatabaseError`.
    public func execute(_ sql: String) throws {
        let status = sqlite3_exec(db, sql, nil, nil, nil)
        try _check(status)
    }

    /// Run multiple statements of SQL with row handler.
    ///
    /// - Parameters:
    ///   - sql: statements.
    ///   - handler: Table row handler.
    /// - Throws: `DatabaseError`.
    public func execute(_ sql: String, handler: @escaping ExecutionHandler) throws {
        var context = handler
        let status = withUnsafeMutableBytes(of: &context) { ctx -> Int32 in
            sqlite3_exec(db, sql, { (ctx, argc, argv, column) -> Int32 in
                var row: [String: String] = [:]
                for i in 0..<Int(argc) {
                    let value = String(cString: argv![i]!)
                    let name = String(cString: column![i]!)
                    row[name] = value
                }
                ctx!.load(as: ExecutionHandler.self)(row)
                return SQLITE_OK
            }, ctx.baseAddress, nil)
        }
        try _check(status)
    }

    /// Check result code.
    ///
    /// - Throws: `DatabaseError` if code not ok.
    private func _check(_ code: Int32) throws {
        guard code != SQLITE_OK else { return }

        let message = String(cString: sqlite3_errstr(code))
        let reason = String(cString: sqlite3_errmsg(db))

        throw DatabaseError(code: code, message: message, reason: reason)
    }

}

private final class ExecutionContext {
    let handler: Database.ExecutionHandler

    init(_ handler: @escaping Database.ExecutionHandler) {
        self.handler = handler
    }
}

private func readRow(
    ctx: UnsafeMutableRawPointer?,
    argc: Int32,
    argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?,
    columns: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
) -> Int32 {
    guard let ctx, let argv, let columns else {
        return SQLITE_OK
    }
    let count = Int(argc)
    var row = [String: String](minimumCapacity: count)

    for index in 0..<count {
        guard let ptr = columns.advanced(by: index).pointee else {
            continue
        }
        let name = String(cString: ptr)
        if let value = argv.advanced(by: index).pointee {
            row[name] = String(cString: value)
        }
    }
    let context = Unmanaged<ExecutionContext>.fromOpaque(ctx).takeUnretainedValue()
    context.handler(row)
    return SQLITE_OK
}
