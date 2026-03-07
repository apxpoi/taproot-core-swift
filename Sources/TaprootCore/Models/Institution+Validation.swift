import Foundation

public enum InstitutionValidationError: Error {
    case invalidIdentifier
    case invalidRegionCode
    case invalidDisplayName
}

public extension Institution {
    func validate() throws {
        guard !id.isEmpty else {
            throw InstitutionValidationError.invalidIdentifier
        }

        let regionCodePattern = /^[A-Z]{2}$/
        guard regionCode.wholeMatch(of: regionCodePattern) != nil else {
            throw InstitutionValidationError.invalidRegionCode
        }

        guard !displayName.isEmpty else {
            throw InstitutionValidationError.invalidDisplayName
        }
    }
}
