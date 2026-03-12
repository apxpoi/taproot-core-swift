import Foundation

public enum AssetValidationError: Error {
    case invalidCurrencyScale
    case invalidQuantityScale
    case invalidValuationTimestamp
    case missingValuationTimestampForMarketAsset
    case invalidUnitType(String)
    case incompatibleUnitType(assetType: String, unitType: String)
}

public extension Asset {
    func validate() throws {
        guard currencyScale >= TaprootLimitsV1.minCurrencyScale, currencyScale <= TaprootLimitsV1.maxCurrencyScale else {
            throw AssetValidationError.invalidCurrencyScale
        }

        guard quantityScale >= TaprootLimitsV1.minQuantityScale, quantityScale <= TaprootLimitsV1.maxQuantityScale else {
            throw AssetValidationError.invalidQuantityScale
        }

        if let valuationAtUnixMs, valuationAtUnixMs <= 0 {
            throw AssetValidationError.invalidValuationTimestamp
        }

        if let assetType = AssetType(rawValue: type), assetType.requiresValuationTimestamp, valuationAtUnixMs == nil {
            throw AssetValidationError.missingValuationTimestampForMarketAsset
        }

        let resolvedUnitTypeID = normalizedUnitTypeID
        guard !resolvedUnitTypeID.isEmpty else {
            return
        }

        if let unitTypeDefinition = AssetUnitType(id: resolvedUnitTypeID) {
            if let assetTypeDefinition, !assetTypeDefinition.supports(unitType: unitTypeDefinition) {
                throw AssetValidationError.incompatibleUnitType(
                    assetType: assetTypeDefinition.id,
                    unitType: resolvedUnitTypeID
                )
            }

            return
        }

        if AssetUnitType.isCustomIdentifier(resolvedUnitTypeID) {
            if let assetTypeDefinition, !assetTypeDefinition.supportsCustomUnitType {
                throw AssetValidationError.incompatibleUnitType(
                    assetType: assetTypeDefinition.id,
                    unitType: resolvedUnitTypeID
                )
            }

            return
        }

        throw AssetValidationError.invalidUnitType(resolvedUnitTypeID)
    }
}
