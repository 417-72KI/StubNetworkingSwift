import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// based on https://github.com/417-72KI/MultipartFormDataParser/blob/main/Tests/MultipartFormDataParserTests/StubURLProtocol.swift
final class StubURLProtocol: URLProtocol {
    #if swift(>=5.10)
    nonisolated(unsafe) private(set) static var stubs: [Stub] = []
    #else
    private(set) static var stubs: [Stub] = []
    #endif

    private static let lock = NSLock()

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        do {
            guard let response = stub(with: request)?.response(request),
                  let url = request.url else {
                throw StubError.unexpectedRequest(request)
            }
            debugLog("Stub response detected for request: \(request)")
            let (data, statusCode, headers) = try response.get()
            debugLog("""
                data: \(data.flatMap { String(data: $0, encoding: .utf8) } ?? data?.base64EncodedString() ?? "(nil)")
                status code: \(statusCode)
                """)

            guard let urlResponse = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: headers
            ) else { throw StubError.responseInitializingFailed(url, statusCode, headers) }

            client?.urlProtocol(self,
                                didReceive: urlResponse,
                                cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // no-op
    }
}

extension StubURLProtocol {
    static func register(_ stub: Stub) {
        lock.lock()
        defer { lock.unlock() }
        stubs.append(stub)
    }

    static func reset() {
        lock.lock()
        defer { lock.unlock() }
        stubs = []
    }
}

private extension StubURLProtocol {
    func stub(with request: URLRequest) -> Stub? {
        Self.stubs
            .last(where: { $0.matcher(request) })
    }
}
