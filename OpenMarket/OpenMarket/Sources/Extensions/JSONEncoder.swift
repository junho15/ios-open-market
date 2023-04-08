import Foundation

extension JSONEncoder {
    func encode<T: Encodable>(from data: T) -> Result<Data, Error> {
        guard let encoded = try? encode(data) else {
            return .failure(OpenMarketError.encodingError)
        }
        return .success(encoded)
    }
}
