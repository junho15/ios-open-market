import Foundation

extension JSONDecoder {
    func decode<T: Decodable>(_ data: Data, to type: T.Type) -> Result<T, Error> {
        guard let decoded = try? decode(type, from: data) else {
            return .failure(OpenMarketError.decodingError)
        }
        return .success(decoded)
    }
}
