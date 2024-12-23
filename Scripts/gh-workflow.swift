#!/usr/bin/env swift

// Workflow commands for GitHub Actions
// https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions
// Usage: xcrun swift-format lint --recursive --strict ./ 2>&1 | Scripts/gh-workflow.swift
// Test: echo "Sources/SQLime/SQLParameter.swift:23:1: warning: [TrailingWhitespace] remove trailing whitespace" | Scripts/gh-workflow.swift

let regex = #/(?<file>.+\.swift):(?<line>\d+):(?<column>\d+): (?<severity>.+): \[(?<title>.+)\] (?<message>.+)/#
while let line = readLine() {
    if let match = try? regex.firstMatch(in: line) {
        let (_, file, line, column, severity, title, message) = match.output
        print("::\(severity) file=\(file),line=\(line),col=\(column),title=\(title)::\(message)")
    } else {
        print(line)
    }
}
