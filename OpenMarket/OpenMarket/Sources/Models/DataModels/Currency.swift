enum Currency: String, Codable, CaseIterable {
    case KRW
    case USD

    var index: Int {
        switch self {
        case .KRW: return 0
        case .USD: return 1
        }
    }

    static func currency(for index: Int) -> Currency? {
        switch index {
        case 0: return .KRW
        case 1: return .USD
        default: return nil
        }
    }
}
