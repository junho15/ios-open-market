import Foundation

protocol Requestable {
    typealias HeaderField = String
    typealias HeaderValue = String

    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HttpMethod { get }
    var headers: [HeaderField: HeaderValue]? { get }
    var httpBody: Data? { get }

    var url: URL? { get }
    var urlRequest: URLRequest? { get }
}

extension Requestable {
    var url: URL? {
        return URL(string: path, relativeTo: baseURL)
    }

    var urlRequest: URLRequest? {
        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.text
        headers?.forEach { headerField, headerValue in
            request.addValue(headerValue, forHTTPHeaderField: headerField)
        }
        request.httpBody = httpBody
        return request
    }
}
