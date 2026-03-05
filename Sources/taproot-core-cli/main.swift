// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Iso3166
import TaprootCore

@main
struct swift_executable {
    static func main() throws {
        guard let snapshotDate = ISO8601DateFormatter().date(from: "2026-03-01T00:00:00Z") else {
            fputs("Invalid demo snapshot date.\n", stderr)
            return
        }

        let spacexAi = Asset(
            type: AssetType.equities.id,
            value: 53_750_000_000_000, // $537.5B with scale 2
            currency: Iso3166.USD.alphabeticCode,
            currencyScale: 2,
            quantity: 43_000_000, // 43.000000% stake with scale 6
            quantityScale: 6,
            unitType: AssetUnitType.ownershipPercent.id,
            symbol: "SPACEX-XAI"
        )

        let tesla = Asset(
            type: AssetType.equities.id,
            value: 17_800_000_000_000, // $178B
            currency: Iso3166.USD.alphabeticCode,
            currencyScale: 2,
            quantity: 507_500_000_000_000, // 507.5M shares with scale 6
            quantityScale: 6,
            unitType: AssetUnitType.share.id,
            symbol: "TSLA"
        )

        let cash = Asset(
            type: AssetType.cash.id,
            value: 50_000_000_000, // $500M
            currency: Iso3166.USD.alphabeticCode,
            currencyScale: 2,
            quantity: 50_000_000_000,
            quantityScale: 2,
            unitType: AssetUnitType.unit.id
        )

        let gold = Asset(
            type: AssetType.commodities.id,
            value: 4_755_700,
            currency: Iso3166.HKD.alphabeticCode,
            currencyScale: 2,
            quantity: 1, // 1 tael is approx. 37.43g to 37.5g
            quantityScale: 0,
            unitType: AssetUnitType.tael.id
        )

        let vault = Vault(
            version: 1,
            createdAt: snapshotDate,
            baseCurrency: Iso3166.USD.alphabeticCode,
            accounts: [
                Account(
                    displayName: "Taproot Bot Wall-E",
                    assets: [
                        spacexAi,
                        tesla,
                        cash,
                    ],
                    institution: Institution(
                        id: "dark_hole",
                        regionCode: "US",
                        displayName: "Dark Hole Private Bank",
                        category: .bank
                    )
                ),

                Account(
                    displayName: "Taproot Team",
                    assets: [
                        gold,
                    ],
                    institution: Institution.default
                ),
            ]
        )

        for account in vault.accounts {
            do {
                try account.institution.validate()
            } catch {
                fputs("Invalid institution in demo data: \(error)\n", stderr)
                return
            }

            for asset in account.assets {
                do {
                    try asset.validate()
                } catch {
                    fputs("Invalid asset in demo data: \(error)\n", stderr)
                    return
                }
            }
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(vault)
        print("----")
        print("Vault bytes ", String(decoding: data, as: UTF8.self))

        let portfolioTotal = vault.accounts
            .flatMap { $0.assets }
            .reduce(Decimal.zero) { $0 + $1.decimalValue }

        print("----")

        print("Demo portfolio total: \(portfolioTotal) \(vault.baseCurrency)")

        let isWithinMaxTotal = portfolioTotal <= TaprootLimitsV1.maxTotalAssetsValue
        print("  Within Taproot max total (\(TaprootLimitsV1.maxTotalAssetsValue)): \(isWithinMaxTotal)")

        guard isWithinMaxTotal else {
            fputs("Demo portfolio exceeds Taproot max total limit.\n", stderr)
            return
        }

        let growthSpace = TaprootLimitsV1.maxTotalAssetsValue - portfolioTotal
        let growthPercent = growthSpace / TaprootLimitsV1.maxTotalAssetsValue * 100
        print("  Growth space to limit: \(growthSpace) \(growthPercent)% \(vault.baseCurrency)")

        print("----")
    }
}
