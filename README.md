# SecureQueryItem

🔐 SecureQueryItem makes it easy to secure sensitive API parameters.

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/) ![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg) ![Platform](https://img.shields.io/badge/platform-iOS%208%20%7C%20macOS%2010.10%20%7C%20tvOS%209%20%7C%20watchOS%202-brightgreen) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Purpose

When working with APIs that require partial (field-level) encryption — where some parameters must be encrypted while others stay in plain text — developers often end up managing **two separate dictionaries**:

- values (e.g, ["username": "Alice", "password": "Hello, Bob!"])
- encryption flags (e.g., ["username": "N", "password": "Y"])

This leads to repetitive, error-prone, and messy code.

Let’s say you’re building a login request between 🤷 Alice (the user) and 🧑‍💻 Bob (the server).  
Meanwhile, 🕵️ Trudy, an attacker lurking on the network, is eager to intercept anything she can.

```swift
let params: [String: String] = [
    "username": "Alice",
    "password": "Hello, Bob!"
]

let encryptionFlags: [String: String] = [
    "username": "N",
    "passwod": "Y"
]
```

What happens?

- 🕵️ Trudy, the attacker on the network, can now see Alice’s password in plaintext. Since `"password"` wasn’t marked for encryption (due to the `"passwod"` typo), it gets sent over the wire unprotected.
- 🧑‍💻 Bob, the server, expects "password" to be encrypted. But he receives a plaintext field instead — or worse, never sees it at all because it’s named "passwod". He shrugs and returns an error, or maybe just logs something silently.
- 🤷 Alice, the user, is left wondering why her login doesn’t work — unaware that her password was just exposed.

⚠️ The real danger?

This kind of bug doesn’t crash.  
It compiles. It runs. It leaks data.  
And unless you’re looking for it, you’ll never know.

**SecureQueryItem** solves this by:

- Representing both plaintext and encrypted fields in a single dictionary
- Automatically encrypting only the necessary fields before sending

Let the code guide you — just follow me.

---

## Usage

### Define parameters:

```swift
let params: SecureQueryItem = [
    "username": "Alice",
    "password": .secure("Hello, Bob!")
]
```

### Define your crypto module:

```swift
final class MyCryptoModule: CryptoProvider {
    static let shared = MyCryptoModule()

    private init() {}
    private var _text: String?

    func encrypt(_ plaintext: String) {
        // encrypt and store internally
    }
    func getSecureText() -> String {
        // return the encrypted result
    }
    func clear() {
        // clear internal encrypted memory if needed
    }
    func decrypt(_ ciphertext: String) -> String {
        // decrypt and return plain text
    }
}
```

### Convert to encrypted [String: String]:

```swift
let bodyData = try? JSONEncoder().encode(
    params.encrypted(using: MyCryptoModule.shared)
)
```

Now you're ready to pass `bodyData` to your URLSession request  —    
then just decrypt the response and you're done.

```swift
Task {
    var request = URLRequest(url: URL(string: "https://example.com/api")!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = bodyData
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        // handling HTTPURLResponse starts
        // ...
        // handling HTTPURLResponse ends
        let envelope = try JSONDecoder().decode(SecureResponse.self, from: data)
        let decryptedJson = MyCryptoModule.shared.decrypt(envelope.data)
        let payload = try JSONDecoder().decode(
            Payload.self, from: .init(decryptedJson.utf8)
        )
        // result handling
    } catch {
        // error handling
    }
}
```

---

## Installation

SecureQueryItem is available via Swift Package Manager.

### Using Xcode:

1. Open your project in Xcode
2. Go to File > Add Packages…
3. Enter the URL:  
```
https://github.com/dsunny90/SecureQueryItem
```
4. Select the version and finish

### Using Package.swift:
```swift
dependencies: [
    .package(url: "https://github.com/dsunny90/SecureQueryItem", from: "1.0.0")
]
```
