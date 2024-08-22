import XCTest
@testable import SecureQueryItem

fileprivate class MockCryptoModule: CryptoProvider {
    private var encryptedText: String?

    func encrypt(_ plainText: String) {
        encryptedText = "encrypted(\(plainText))"
    }

    func getSecureText() -> String {
        return encryptedText ?? ""
    }

    func clear() {
        encryptedText = nil
    }

    func decrypt(_ cipherText: String) -> String {
        return "decrypted(\(cipherText))"
    }
}

final class SecureQueryItemTests: XCTestCase {
    func testOnlyPlainText() {
        let query: SecureQueryItem = [
            "Alice": "I am Alice"
        ]
        let module = MockCryptoModule()
        let result = query.encrypted(using: module)

        XCTAssertEqual(result["Alice"], "I am Alice")
    }

    func testOnlySecureText() {
        let query: SecureQueryItem = [
            "Bob": .secure("I am Bob")
        ]
        let module = MockCryptoModule()
        let result = query.encrypted(using: module)

        XCTAssertEqual(result["Bob"], "encrypted(I am Bob)")
    }

    func testMixedText() {
        let query: SecureQueryItem = [
            "Alice": .secure("I am Alice"),
            "Bob": .plain("I am Bob"),
            "Carol": "I am Carol",
            "Dave": .secure("I am Dave")
        ]
        let module = MockCryptoModule()
        let result = query.encrypted(using: module)

        XCTAssertEqual(result["Alice"], "encrypted(I am Alice)")
        XCTAssertEqual(result["Bob"], "I am Bob")
        XCTAssertEqual(result["Carol"], "I am Carol")
        XCTAssertEqual(result["Dave"], "encrypted(I am Dave)")
    }
}
