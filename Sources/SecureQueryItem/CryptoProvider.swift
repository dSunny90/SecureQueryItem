//
//  CryptoProvider.swift
//  SecureQueryItem
//
//  Created by SunSoo Jeon on 22.08.2024.
//

import Foundation

/// A protocol for handling field-level encryption of sensitive string values.
///
/// Types conforming to `CryptoProvider` can securely encrypt and decrypt text,
/// typically for use in API payloads containing fields like passwords or tokens.
///
/// Conforming types often store the encrypted result in memory
/// using a private property, encapsulating sensitive state
/// and making it important to clear that storage after use to avoid leaking data.
///
/// It supports modular encryption module, whether Swift-native or C-based.
///
/// - Example:
/// ```swift
///final class MyCryptoModule: CryptoProvider {
///    static let shared = MyCryptoModule()
///
///    // Stores encrypted C string (must be freed manually)
///    private var _cText: UnsafeMutablePointer<CUnsignedChar>?
///
///    private init() {}
///
///    func encrypt(_ plaintext: String) {
///        // C-style: use cString + withUnsafeMutableBufferPointer
///        // Swift-style: pass plaintext to Swift crypto
///    }
///
///    func getSecureText() -> String {
///        // C-style: String(cString:) or Data(buffer)
///        // Swift-style: return stored encrypted string
///    }
///
///    func clear() {
///        // C-style: free memory + set pointer = nil
///        // Swift-style: clear string or set to nil
///    }
///
///    func decrypt(_ ciphertext: String) -> String {
///        // C-style: use cString + unsafe buffer pointer
///        // Swift-style: return decrypted string
///    }
///}
/// ```
public protocol CryptoProvider {
    /// Encrypts the given plaintext and stores the encrypted result internally.
    /// - Parameter plaintext: The string to be encrypted.
    func encrypt(_ plaintext: String)
    /// Retrieves the most recently encrypted string.
    /// - Returns: The encrypted result as a string.
    func getSecureText() -> String
    /// Clears any internal encrypted state.
    func clear()
    /// Decrypts the given ciphertext and returns the plaintext.
    /// - Parameter ciphertext: The encrypted string.
    /// - Returns: The decrypted plain text.
    func decrypt(_ ciphertext: String) -> String
}
