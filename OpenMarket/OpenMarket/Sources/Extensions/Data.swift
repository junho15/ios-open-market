import Foundation

extension Data {
    mutating func append(_ newElement: String) {
        if let newData = newElement.data(using: .utf8) {
            self.append(newData)
        }
    }
}
