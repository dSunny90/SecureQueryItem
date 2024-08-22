//
//  SecureQueryItem.swift
//  SecureQueryItem
//
//  Created by SunSoo Jeon on 22.08.2024.
//

import Foundation

/// A lightweight dictionary that holds both plain and encrypted values.
/// Ideal for building secure API parameters without managing two dictionaries.
public struct SecureQueryItem: ExpressibleByDictionaryLiteral {
    /// Represents either a plain or encryptable value in the dictionary.
    public enum Text {
        case plain(String)
        case secure(String)
    }

    private var query: [String: Text] = [:]

    public init(dictionaryLiteral elements: (String, Text)...) {
        for (key, value) in elements {
            query[key] = value
        }
    }

    public subscript(key: String) -> Text? {
        return query[key]
    }

    /// Converts the dictionary into a `[String: String]`,
    /// encrypting secure values using the given provider.
    public func encrypted(
        using cryptoProvider: CryptoProvider
    ) -> [String: String] {
        query.mapValues { value in
            let queryItemValue: String
            switch value {
            case .plain(let plainText):
                queryItemValue = plainText
            case .secure(let plainText):
                cryptoProvider.encrypt(plainText)
                queryItemValue = cryptoProvider.getSecureText()
                cryptoProvider.clear()
            }
            return queryItemValue
        }
    }
}

extension SecureQueryItem {
    /// A sugar method that converts the encrypted dictionary
    /// into a URL query string. Internally uses `encrypted(using:)`
    /// to process encryption.
    public func encryptedQuery(using cryptoProvider: CryptoProvider) -> String {
        encrypted(using: cryptoProvider).asQueryString()
    }
}

extension SecureQueryItem.Text: ExpressibleByStringLiteral {
    public init(stringLiteral text: StringLiteralType) {
        self = .plain(text)
    }
}

extension Dictionary where Key == String, Value == String {
    /// Converts dictionary into a URL-encoded query string.
    public func asQueryString() -> String {
        var result = ""
        var isFirst = true
        for (key, value) in self {
            guard
                let encodedKey = key.urlEncoded,
                let encodedValue = value.urlEncoded
            else {
                continue
            }
            // Add '&' only after the first key-value pair
            if isFirst {
                isFirst = false
            } else {
                result.append("&")
            }
            result.append("\(encodedKey)=\(encodedValue)")
        }
        return result
    }
}

private extension String {
    var urlEncoded: String? {
        self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
