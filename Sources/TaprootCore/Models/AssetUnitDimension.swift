public enum AssetUnitDimension: String, Codable, CaseIterable, Identifiable, Hashable {
  case count
  case mass
  case area
  case ratio
  case other

  public var id: String {
    return rawValue
  }
}
