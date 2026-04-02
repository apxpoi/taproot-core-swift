@testable import TaprootCore
import XCTest

final class InstitutionTests: XCTestCase {
    func testInitializerNormalizesIDAndRegionAndPreservesDisplayFields() {
        let institution = Institution(
            id: "  hsbc  ",
            regionCode: " hk ",
            displayName: " HSBC Hong Kong ",
            description: "  Retail and private banking  ",
            category: .bank
        )

        XCTAssertEqual(institution.id, "hsbc")
        XCTAssertEqual(institution.regionCode, "HK")
        XCTAssertEqual(institution.displayName, " HSBC Hong Kong ")
        XCTAssertEqual(institution.description, "  Retail and private banking  ")
        XCTAssertEqual(institution.category, .bank)
    }

    func testInitializerUsesFallbacksWhenRequiredFieldsAreEmpty() {
        let institution = Institution(
            id: "   ",
            regionCode: "  ",
            displayName: "  "
        )

        XCTAssertEqual(institution.id, Institution.default.id)
        XCTAssertEqual(institution.regionCode, Institution.default.regionCode)
        XCTAssertEqual(institution.displayName, "  ")
    }

    func testInitializerUsesFallbackDisplayNameWhenDisplayNameIsTrulyEmpty() {
        let institution = Institution(
            id: "broker-001",
            regionCode: "US",
            displayName: ""
        )

        XCTAssertEqual(institution.displayName, "broker-001")
    }

    func testCanonicalIDIsNormalizedForLookup() {
        let institution = Institution(id: "HSBC", regionCode: "hk", displayName: "HSBC")
        XCTAssertEqual(institution.canonicalID, "HK::HSBC")
    }

    func testCanonicalIDUppercasesSwiftBICLikeIdentifier() {
        let institution = Institution(id: "hsbchkhhxxx", regionCode: "hk", displayName: "HSBC HK")
        XCTAssertEqual(institution.canonicalID, "HK::HSBCHKHHXXX")
    }

    func testEncodeProducesObjectValue() throws {
        let institution = Institution(
            id: "fidelity",
            regionCode: "US",
            displayName: "Fidelity",
            description: "Brokerage",
            category: .brokerage
        )
        let data = try JSONEncoder().encode(institution)
        let object = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(object["id"] as? String, "fidelity")
        XCTAssertEqual(object["regionCode"] as? String, "US")
        XCTAssertEqual(object["displayName"] as? String, "Fidelity")
        XCTAssertEqual(object["description"] as? String, "Brokerage")
        XCTAssertEqual(object["category"] as? String, "brokerage")
    }

    func testDecodeFromStringValueThrows() {
        let data = Data("\"coinbase\"".utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(Institution.self, from: data))
    }

    func testDecodeFromObjectValue() throws {
        let data = Data(
            """
            {
              "id": "coinbase",
              "regionCode": "US",
              "displayName": "Coinbase",
              "description": "Crypto exchange",
              "category": "cryptoExchange"
            }
            """.utf8
        )
        let institution = try JSONDecoder().decode(Institution.self, from: data)
        XCTAssertEqual(institution.id, "coinbase")
        XCTAssertEqual(institution.regionCode, "US")
        XCTAssertEqual(institution.displayName, "Coinbase")
        XCTAssertEqual(institution.description, "Crypto exchange")
        XCTAssertEqual(institution.category, .cryptoExchange)
    }

    func testValidateAcceptsValidInstitution() {
        let institution = Institution(
            id: "fidelity",
            regionCode: "US",
            displayName: "Fidelity"
        )

        XCTAssertNoThrow(try institution.validate())
    }

    func testValidateRejectsInvalidRegionCode() {
        let institution = Institution(
            id: "fidelity",
            regionCode: "USA",
            displayName: "Fidelity"
        )

        XCTAssertThrowsError(try institution.validate()) { error in
            guard case InstitutionValidationError.invalidRegionCode = error else {
                return XCTFail("Expected invalidRegionCode, got: \(error)")
            }
        }
    }

    func testInstitutionCategoryDisplayMetadataIsComplete() {
        for category in InstitutionCategory.allCases {
            XCTAssertFalse(category.displayName.isEmpty)
            XCTAssertFalse(category.displayDescription.isEmpty)
        }
    }

    func testInstitutionCategoryIDsUseCaseNames() {
        let expectedIDs: [InstitutionCategory: String] = [
            .bank: "bank",
            .brokerage: "brokerage",
            .cryptoExchange: "cryptoExchange",
            .paymentProvider: "paymentProvider",
            .wallet: "wallet",
            .other: "other",
        ]

        for (category, expectedID) in expectedIDs {
            XCTAssertEqual(category.id, expectedID)
            XCTAssertEqual(category.id, String(describing: category))
            XCTAssertEqual(InstitutionCategory(rawValue: category.id), category)
        }
    }

    func testInstitutionCategoryExamplesAreClearForCommonProviders() {
        XCTAssertTrue(InstitutionCategory.bank.displayDescription.contains("Licensed banks"))
        XCTAssertTrue(InstitutionCategory.paymentProvider.displayDescription.contains("Apple Pay"))
        XCTAssertTrue(InstitutionCategory.paymentProvider.displayDescription.contains("Wise"))
        XCTAssertTrue(InstitutionCategory.paymentProvider.displayDescription.contains("PayPal"))
    }
}
