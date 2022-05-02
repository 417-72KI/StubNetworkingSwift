import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class Stub {
    typealias Response = (URLRequest) -> StubResponse

    private(set) var condition: StubCondition
    private(set) var response: Response

    init(condition: @escaping StubCondition = alwaysTrue,
         response: @escaping Response = errorResponse(.unimplemented)) {
        self.condition = condition
        self.response = response
    }
}

// MARK: - Method chain builders
@discardableResult
public func stub(url: URL? = nil,
                 method: Method? = nil,
                 file: StaticString = #file,
                 line: UInt = #line) -> Stub {
    let condition = stub {
        if let url = url {
            let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let scheme = comps?.scheme {
                Scheme.is(scheme, file: file, line: line)
            }
            if let host = comps?.host {
                Host.is(host, file: file, line: line)
            }
            if let path = comps?.path {
                Path.is(path, file: file, line: line)
            }
            if let queryItems = comps?.queryItems {
                QueryParams.contains(queryItems, file: file, line: line)
            }
        }
        if let method = method {
            method.condition(file: file, line: line)
        }
    }
    return Stub(condition: condition)
}

@discardableResult
public func stub(url: String,
                 method: Method? = nil,
                 file: StaticString = #file,
                 line: UInt = #line) -> Stub {
    stub(url: URL(string: url), method: method, file: file, line: line)
}

// MARK: Scheme
public extension Stub {
    @discardableResult
    func scheme(_ scheme: String,
                file: StaticString = #file,
                line: UInt = #line) -> Self {
        condition &&= Scheme.is(scheme, file: file, line: line)
        return self
    }
}

// MARK: Host
public extension Stub {
    @discardableResult
    func host(_ host: String,
              file: StaticString = #file,
              line: UInt = #line) -> Self {
        condition &&= Host.is(host, file: file, line: line)
        return self
    }
}

// MARK: Path
public extension Stub {
    @discardableResult
    func path(_ path: String,
              file: StaticString = #file,
              line: UInt = #line) -> Self {
        condition &&= Path.is(path, file: file, line: line)
        return self
    }
}

// MARK: PathExtension
public extension Stub {
    @discardableResult
    func pathExtension(_ ext: String,
                       file: StaticString = #file,
                       line: UInt = #line) -> Self {
        condition &&= Extension.is(ext, file: file, line: line)
        return self
    }
}

// MARK: Method
public extension Stub {
    @discardableResult
    func method(_ method: Method,
                file: StaticString = #file,
                line: UInt = #line) -> Self {
        condition &&= method.condition(file: file, line: line)
        return self
    }
}

// MARK: QueryParams
public extension Stub {
    @discardableResult
    func queryParams(_ queryParams: [String: String?],
                     file: StaticString = #file,
                     line: UInt = #line) -> Self {
        condition &&= QueryParams.contains(queryParams, file: file, line: line)
        return self
    }

    @discardableResult
    func queryItems(_ queryItems: [URLQueryItem],
                    file: StaticString = #file,
                    line: UInt = #line) -> Self {
        condition &&= QueryParams.contains(queryItems, file: file, line: line)
        return self
    }

    @discardableResult
    func queryParams(_ queryParams: [String],
                     file: StaticString = #file,
                     line: UInt = #line) -> Self {
        condition &&= QueryParams.contains(queryParams, file: file, line: line)
        return self
    }
}

// MARK: Header
public extension Stub {
    @discardableResult
    func header(_ name: String,
                file: StaticString = #file,
                line: UInt = #line) -> Self {
        condition &&= Header.contains(name, file: file, line: line)
        return self
    }

    @discardableResult
    func header(_ name: String,
                value: String,
                file: StaticString = #file,
                line: UInt = #line) -> Self {
        condition &&= Header.contains(name, withValue: value, file: file, line: line)
        return self
    }
}

// MARK: Body
public extension Stub {
    @discardableResult
    func body(_ body: Data,
              file: StaticString = #file,
              line: UInt = #line) -> Self {
        condition &&= Body.is(body, file: file, line: line)
        return self
    }

    @discardableResult
    func jsonBody(_ jsonObject: [AnyHashable: Any],
                  file: StaticString = #file,
                  line: UInt = #line) -> Self {
        condition &&= Body.isJson(jsonObject, file: file, line: line)
        return self
    }

    @discardableResult
    func jsonBody(_ jsonArray: [Any],
                  file: StaticString = #file,
                  line: UInt = #line) -> Self {
        condition &&= Body.isJson(jsonArray, file: file, line: line)
        return self
    }

    @discardableResult
    func formBody(_ queryItems: [URLQueryItem],
                  file: StaticString = #file,
                  line: UInt = #line) -> Self {
        condition &&= Body.isForm(queryItems, file: file, line: line)
        return self
    }

    @discardableResult
    func formBody(_ queryItems: [String: String?],
                  file: StaticString = #file,
                  line: UInt = #line) -> Self {
        condition &&= Body.isForm(queryItems, file: file, line: line)
        return self
    }

    @discardableResult
    func formBody(_ queryItems: URLQueryItem...,
                  file: StaticString = #file,
                  line: UInt = #line) -> Self {
        formBody(queryItems, file: file, line: line)
    }
}

// MARK: -
func errorResponse(_ error: StubError) -> Stub.Response {
    { _ in .failure(error) }
}