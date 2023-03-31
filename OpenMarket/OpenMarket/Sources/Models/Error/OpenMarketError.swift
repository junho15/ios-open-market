import Foundation

enum OpenMarketError: Error {
    case decodingError
    case invalidRequest
    case networkError(error: Error)
    case badStatus
    case emptyData

    var localizedDescription: String {
        switch self {
        case .decodingError:
            return NSLocalizedString("Decoding Error", comment: "Decoding Error")
        case .invalidRequest:
            return NSLocalizedString("Invalid Request", comment: "Invalid Request")
        case .networkError(let error):
            return NSLocalizedString("Network Error: \(error.localizedDescription)", comment: "Network Error")
        case .badStatus:
            return NSLocalizedString("Bad Status", comment: "Bad Status")
        case .emptyData:
            return NSLocalizedString("Data is Empty", comment: "Data is Empty")
        }
    }
}
