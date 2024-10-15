#if compiler(<6.0)
import Foundation
import Testing

/// This struct in `swift-testing` for Swift 5.10 is `@_spi`
public struct ParallelizationTrait: TestTrait, SuiteTrait {
    public var isRecursive: Bool {
        true
    }
}

extension Trait where Self == ParallelizationTrait {
    /// A trait that serializes the test to which it is applied.
    ///
    /// ## See Also
    ///
    /// - ``ParallelizationTrait``
    public static var serialized: Self {
        Self()
    }
}
#endif
