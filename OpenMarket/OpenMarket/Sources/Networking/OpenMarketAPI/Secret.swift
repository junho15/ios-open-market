struct Secret: Encodable {
    let password: String

    private enum CodingKeys: String, CodingKey {
        case password = "secret"
    }
}
