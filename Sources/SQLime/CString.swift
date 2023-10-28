extension Optional<UnsafePointer<CChar>> {
    @inlinable
    var string: String? {
        self.map { String(cString: $0) }
    }
}
