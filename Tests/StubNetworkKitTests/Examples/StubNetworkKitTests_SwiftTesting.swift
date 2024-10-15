import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
import StubNetworkKit

@Suite(.serialized)
final class StubNetworkKitTests_SwiftTesting {
    init() {
        StubNetworking.option(printDebugLog: true,
                              debugConditions: true)
    }

    // deinit { clearStubs() }

    /// Example function for basic implementation
    @Test func defaultStubSession_basic() async throws {
        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz"))
            .responseData("Hello world!".data(using: .utf8)!)

        let (data, response) = try await defaultStubSession.data(from: url)
        #expect(String(data: data, encoding: .utf8) == "Hello world!")
        #expect((response as? HTTPURLResponse)?.statusCode == 200)
    }

    #if !os(watchOS)
    /// Example function for basic implementation
    @Test func defaultStubSession_basic_post() async throws {
        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz") && Method.isPost() && Body.isJson(["key": "world"]))
            .responseData("Hello world!".data(using: .utf8)!)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = #"{"key": "world"}"#.data(using: .utf8)

        let (data, response) = try await defaultStubSession.data(for: request)
        #expect(String(data: data, encoding: .utf8) == "Hello world!")
        #expect((response as? HTTPURLResponse)?.statusCode == 200)
    }
    #endif

    /// Example function for basic implementation
    @Test func defaultStubSession_basic_customResponse() async throws {
        let url = URL(string: "foo://bar/baz?q=1")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz")) {
            guard $0.url?.query == "q=1" else {
                return .error(.unexpectedRequest($0))
            }
            return .data("Hello world!".data(using: .utf8)!)
        }

        let (data, response) = try await defaultStubSession.data(from: url)
        #expect(String(data: data, encoding: .utf8) == "Hello world!")
        #expect((response as? HTTPURLResponse)?.statusCode == 200)
    }

    /// Example function for using Result Builder implementation
    @Test func defaultStubSession_resultBuilder() async throws {
        let url = URL(string: "foo://bar/baz")!
        stub {
            Scheme.is("foo")
            Host.is("bar")
            Path.is("/baz")
            Method.isGet()
        }.responseData("Hello world!".data(using: .utf8)!)

        let (data, response) = try await defaultStubSession.data(from: url)
        #expect(String(data: data, encoding: .utf8) == "Hello world!")
        #expect((response as? HTTPURLResponse)?.statusCode == 200)
    }

    #if !os(watchOS)
    /// Example function for using Result Builder implementation
    @Test func defaultStubSession_resultBuilder_post() async throws {
        let url = URL(string: "foo://bar/baz")!

        stub {
            Scheme.is("foo")
            Host.is("bar")
            Path.is("/baz")
            Method.isPost()
            Body.isJson(["key": "world"])
        }.responseData("Hello world!".data(using: .utf8)!)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = #"{"key": "world"}"#.data(using: .utf8)

        let (data, response) = try await defaultStubSession.data(for: request)
        #expect(String(data: data, encoding: .utf8) == "Hello world!")
        #expect((response as? HTTPURLResponse)?.statusCode == 200)
    }
    #endif

    /// Example function for using Result Builder implementation
    @Test func defaultStubSession_resultBuilder_customResponse() async throws {
        let url = URL(string: "foo://bar/baz?q=1")!

        stub {
            Scheme.is("foo")
            Host.is("bar")
            Path.is("/baz")
            Method.isGet()
        } withResponse: {
            guard $0.url?.query == "q=1" else {
                return .error(.unexpectedRequest($0))
            }
            return .data("Hello world!".data(using: .utf8)!)
        }

        let (data, response) = try await defaultStubSession.data(from: url)
        #expect(String(data: data, encoding: .utf8) == "Hello world!")
        #expect((response as? HTTPURLResponse)?.statusCode == 200)
    }

    /// Example function for using single function implementation
    @Test func defaultStubSession_singleFunction() async throws {
        let url = URL(string: "foo://bar/baz")!
        stub(url: "foo://bar/baz", method: .get)
            .responseData("Hello world!".data(using: .utf8)!)

        let (data, response) = try await defaultStubSession.data(from: url)
        #expect(String(data: data, encoding: .utf8) == "Hello world!")
        #expect((response as? HTTPURLResponse)?.statusCode == 200)
    }

    /// Example function for using function-chain implementation
    @Test func defaultStubSession_functionChaining() async throws {
        let url = URL(string: "foo://bar/baz")!
        stub()
            .scheme("foo")
            .host("bar")
            .path("/baz")
            .method(.get)
            .responseData("Hello world!".data(using: .utf8)!)

        let (data, response) = try await defaultStubSession.data(from: url)
        #expect(String(data: data, encoding: .utf8) == "Hello world!")
        #expect((response as? HTTPURLResponse)?.statusCode == 200)
    }

    /// Example function for using fixture response.
    @Test func defaultStubSession_fixture() async throws {
        let url = URL(string: "foo://bar/baz?q=1")!
        stub {
            Scheme.is("foo")
            Host.is("bar")
            Path.is("/baz")
            Method.isGet()
        } withResponse: {
            guard $0.url?.query == "q=1" else {
                return .error(.unexpectedRequest($0))
            }
            return .json(fromFile: "_Fixtures/sample", in: .module)
        }

        let (data, response) = try await defaultStubSession.data(from: url)
        #expect((response as? HTTPURLResponse)?.statusCode == 200)

        let actual = try JSONDecoder()
            .decode(Sample.self, from: data)
        #expect(
            actual == .init(
                foo: "hoge",
                bar: 42,
                baz: true,
                qux: .init(
                    quux: "fuga",
                    corge: 3.14,
                    grault: false,
                    garply: [
                        "spam",
                        "ham",
                        "eggs"
                    ]
                )
            )
        )
    }

    /// Example function for using function-chain implementation and fixture response.
    @Test func defaultStubSession_functionChaining_fixture() async throws {
        let url = URL(string: "foo://bar/baz")!
        stub()
            .scheme("foo")
            .host("bar")
            .path("/baz")
            .method(.get)
            .responseData(withFilePath: "_Fixtures/sample", extension: "json", in: .module)

        let (data, response) = try await defaultStubSession.data(from: url)
        #expect((response as? HTTPURLResponse)?.statusCode == 200)

        let actual = try JSONDecoder()
            .decode(Sample.self, from: data)
        #expect(actual == .init(foo: "hoge",
                                     bar: 42,
                                     baz: true,
                                     qux: .init(
                                        quux: "fuga",
                                        corge: 3.14,
                                        grault: false,
                                        garply: [
                                            "spam",
                                            "ham",
                                            "eggs"
                                        ]
                                     )
                                    )
        )
    }

    /// Example function for intercepting `URLSession.shared` requests
    @Test func sharedSession() async throws {
        registerStubForSharedSession()
        defer { unregisterStubForSharedSession() }

        let url = URL(string: "foo://bar/baz")!

        stub(Scheme.is("foo") && Host.is("bar") && Path.is("/baz"))
            .responseData("Hello world!".data(using: .utf8)!)

        let (data, response) = try await defaultStubSession.data(from: url)
        #expect(String(data: data, encoding: .utf8) == "Hello world!")
        #expect((response as? HTTPURLResponse)?.statusCode == 200)
    }
}

private extension StubNetworkKitTests_SwiftTesting {
    struct Sample: Decodable, Equatable {
        var foo: String
        var bar: Int
        var baz: Bool
        var qux: Qux

        struct Qux: Decodable, Equatable {
            var quux: String
            var corge: Decimal
            var grault: Bool
            var garply: [String]
        }
    }
}
