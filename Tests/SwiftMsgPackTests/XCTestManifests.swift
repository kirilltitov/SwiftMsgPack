import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SwiftMsgPackTests_Array.allTests),
        testCase(SwiftMsgPackTests_BoolNil.allTests),
        testCase(SwiftMsgPackTests_Data.allTests),
        testCase(SwiftMsgPackTests_Dictionary.allTests),
        testCase(SwiftMsgPackTests_Numeric.allTests),
        testCase(SwiftMsgPackTests_String.allTests),
    ]
}
#endif
