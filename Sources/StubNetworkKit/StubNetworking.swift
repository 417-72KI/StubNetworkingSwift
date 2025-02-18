import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum StubNetworking: Sendable {
    #if swift(>=5.10)
    nonisolated(unsafe) private static var _option = defaultOption
    #else
    private static var _option = defaultOption
    #endif
}

extension StubNetworking {
    static var option: Option { _option }
}

public extension StubNetworking {
    static func option(
        printDebugLog: Bool,
        debugConditions: Bool
    ) {
        _option = .init(
            printDebugLog: printDebugLog,
            debugConditions: debugConditions
        )
    }
}

// TODO: Will be `internal` on next major
public extension StubNetworking {
    struct Option: Sendable {
        public var printDebugLog: Bool
        public var debugConditions: Bool

        public init(printDebugLog: Bool,
                    debugConditions: Bool) {
            self.printDebugLog = printDebugLog
            self.debugConditions = debugConditions
        }
    }
}

extension StubNetworking {
    static let defaultOption = Option(printDebugLog: false,
                                      debugConditions: false)
}

// MARK: - Setup stub

public var defaultStubSession: URLSession {
    let configuration = URLSessionConfiguration.ephemeral
    registerStub(to: configuration)
    return URLSession(configuration: configuration)
}

public func registerStub(to configuration: URLSessionConfiguration) {
    configuration.protocolClasses = [StubURLProtocol.self]
}

// NOTE: Testing on watchOS(~8), `StubURLProtocol.startLoading` isn't called, although `canInit` has been called.
/// Handle all requests via `URLSession.shared`
@available(watchOS, introduced: 9, message: "Intercepting `URLSession.shared` is unavailable in watchOS(~8).")
public func registerStubForSharedSession() {
    assert(URLProtocol.registerClass(StubURLProtocol.self))
}

@available(watchOS, introduced: 9, message: "Intercepting `URLSession.shared` is unavailable in watchOS(~8).")
public func unregisterStubForSharedSession() {
    URLProtocol.unregisterClass(StubURLProtocol.self)
}

// MARK: - logger
func debugLog(_ message: Any,
              file: StaticString = #file,
              line: UInt = #line) {
    guard StubNetworking.option.printDebugLog else { return }
    let file = file.description.split(separator: "/").last!

    print("\u{001B}[33m[\(file):L\(line)] \(message)\u{001B}[m")
}

func dumpCondition<T: Equatable>(expected: T?,
                                 actual: T?,
                                 file: StaticString = #file,
                                 line: UInt = #line) {
    guard StubNetworking.option.debugConditions else { return }
    let file = file.description.split(separator: "/").last!
    let expected = unwrap(expected)
    let actual = unwrap(actual)
    let result = (expected == actual)
    print("\u{001B}[\(result ? 32 : 31)m[\(file):L\(line)] expected: \(expected), actual: \(actual)\u{001B}[m")
}

func dumpCondition(expected: JSONArray?,
                   actual: JSONArray?,
                   file: StaticString = #file,
                   line: UInt = #line) {
    guard StubNetworking.option.debugConditions else { return }
    let file = file.description.split(separator: "/").last!
    let result: Bool = switch (expected, actual) {
    case let (expected?, actual?):
        NSArray(array: expected)
            .isEqual(to: actual)
    case (nil, nil): true
    default: false
    }
    print("\u{001B}[\(result ? 32 : 31)m[\(file):L\(line)] expected: \(String(describing: expected)), actual: \(String(describing: actual))\u{001B}[m")
}

func dumpCondition(expected: JSONObject?,
                   actual: JSONObject?,
                   file: StaticString = #file,
                   line: UInt = #line) {
    guard StubNetworking.option.debugConditions else { return }
    let file = file.description.split(separator: "/").last!
    let result: Bool = switch (expected, actual) {
    case let (expected?, actual?):
        NSDictionary(dictionary: expected)
            .isEqual(to: actual)
    case (nil, nil): true
    default: false
    }

    print("\u{001B}[\(result ? 32 : 31)m[\(file):L\(line)] expected: \(String(describing: expected)), actual: \(String(describing: actual))\u{001B}[m")
}

private func unwrap<T: Equatable>(_ value: T?) -> String {
    let pattern = #"Optional\((.+)\)"#
    return String(describing: value)
        .replacingOccurrences(of: pattern,
                              with: "$1",
                              options: .regularExpression,
                              range: nil)
        .replacingOccurrences(of: pattern,
                              with: "$1",
                              options: .regularExpression,
                              range: nil)
}
