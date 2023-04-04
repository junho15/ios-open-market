import Foundation

extension NumberFormatter {
    private static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    static func decimalString<T: Numeric>(_ number: T) -> String? {
        return decimalFormatter.string(for: number)
    }
}
