import XCTest
@testable import OpenMarket

final class JSONDecodingTests: XCTestCase {
    func test_유효한JSON데이터를_올바르게디코딩하는지() throws {
        // given
        let data = validData

        // when
        let page = try JSONDecoder().decode(Page.self, from: data)

        // then
        XCTAssertEqual(page.pageNumber, 1)
        XCTAssertEqual(page.products[0].id, 1944)
        XCTAssertEqual(page.products[0].currency, .KRW)
    }

    func test_유효하지않은JSON데이터를_디코딩하면_에러를반환하는지() {
        // given
        let data = invalidData

        // when, then
        XCTAssertThrowsError(try JSONDecoder().decode(Page.self, from: data))
    }
}

// swiftlint:disable line_length
extension JSONDecodingTests {
    private var validData: Data { return """
        {
            "pageNo": 1,
            "itemsPerPage": 3,
            "totalCount": 1182,
            "offset": 0,
            "limit": 3,
            "lastPage": 394,
            "hasNext": true,
            "hasPrev": false,
            "pages": [
                {
                    "id": 1944,
                    "vendor_id": 50,
                    "vendorName": "kyo12",
                    "name": "전신 패딩 판매합니다.",
                    "description": "전신 패딩 팝니다. 개당 가격 5만. 네고 사절",
                    "thumbnail": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/50/20230323/e0cace5bc94f11edacadc9b8d0b5fbbf_thumb",
                    "currency": "KRW",
                    "price": 50000.0,
                    "bargain_price": 50000.0,
                    "discounted_price": 0.0,
                    "stock": 2,
                    "created_at": "2023-03-23T00:00:00",
                    "issued_at": "2023-03-23T00:00:00"
                },
                {
                    "id": 1942,
                    "vendor_id": 50,
                    "vendorName": "kyo12",
                    "name": "패딩판매합니다",
                    "description": "패딩판매합니다. 이번에 안팔리면 그냥 제가 입을게요",
                    "thumbnail": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/50/20230323/b96fe2a5c94f11edacad2f53e97775d4_thumb",
                    "currency": "KRW",
                    "price": 300000.0,
                    "bargain_price": 20000.0,
                    "discounted_price": 280000.0,
                    "stock": 1,
                    "created_at": "2023-03-23T00:00:00",
                    "issued_at": "2023-03-23T00:00:00"
                },
                {
                    "id": 1941,
                    "vendor_id": 50,
                    "vendorName": "kyo12",
                    "name": "아이폰 판매합니다.",
                    "description": "아이폰 퍼플 판매합니다. 직거래만해여 직거래 장소 잠실입니다",
                    "thumbnail": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/50/20230323/31cf4612c94f11edacad8d46aae68fd0_thumb",
                    "currency": "KRW",
                    "price": 900000.0,
                    "bargain_price": 880000.0,
                    "discounted_price": 20000.0,
                    "stock": 1,
                    "created_at": "2023-03-23T00:00:00",
                    "issued_at": "2023-03-23T00:00:00"
                }
            ]
        }
        """.data(using: .utf8)!
    }

    private var invalidData: Data { """
        {
            "pageNo": 1,
            "itemsPerPage": 3,
            "totalCount": 1182,
            "offset": 0,
            "limit": 3,
            "lastPage": 394,
            "hasNext": true,
            "hasPrev": false,
            "pages": [
                {
                    "vendor_id": 50,
                    "vendorName": "kyo12",
                    "name": "전신 패딩 판매합니다.",
                    "description": "전신 패딩 팝니다. 개당 가격 5만. 네고 사절",
                    "thumbnail": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/50/20230323/e0cace5bc94f11edacadc9b8d0b5fbbf_thumb",
                    "currency": "KRW",
                    "price": 50000.0,
                    "bargain_price": 50000.0,
                    "discounted_price": 0.0,
                    "stock": 2,
                    "created_at": "2023-03-23T00:00:00",
                    "issued_at": "2023-03-23T00:00:00"
                },
                {
                    "vendor_id": 50,
                    "vendorName": "kyo12",
                    "name": "패딩판매합니다",
                    "description": "패딩판매합니다. 이번에 안팔리면 그냥 제가 입을게요",
                    "thumbnail": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/50/20230323/b96fe2a5c94f11edacad2f53e97775d4_thumb",
                    "currency": "KRW",
                    "price": 300000.0,
                    "bargain_price": 20000.0,
                    "discounted_price": 280000.0,
                    "stock": 1,
                    "created_at": "2023-03-23T00:00:00",
                    "issued_at": "2023-03-23T00:00:00"
                },
                {
                    "vendor_id": 50,
                    "vendorName": "kyo12",
                    "name": "아이폰 판매합니다.",
                    "description": "아이폰 퍼플 판매합니다. 직거래만해여 직거래 장소 잠실입니다",
                    "thumbnail": "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/50/20230323/31cf4612c94f11edacad8d46aae68fd0_thumb",
                    "currency": "KRW",
                    "price": 900000.0,
                    "bargain_price": 880000.0,
                    "discounted_price": 20000.0,
                    "stock": 1,
                    "created_at": "2023-03-23T00:00:00",
                    "issued_at": "2023-03-23T00:00:00"
                }
            ]
        }
        """.data(using: .utf8)!
    }
}
