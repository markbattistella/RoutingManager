//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// Generates a stable, hierarchical identifier for navigation types.
///
/// This function uses reflection to create identifiers in the format:
/// `<prefix>.<TypeName>.<caseName>[.<associatedValues>]`
///
/// The generated identifiers are:
/// - **Stable**: Same input always produces the same output across app launches
/// - **Unique**: Each case and associated value combination produces a distinct identifier
/// - **Hierarchical**: Uses dot notation for easy parsing and deep linking
/// - **Human-readable**: Includes type and case names for debugging
///
/// - Parameters:
///   - value: The navigation type instance to generate an identifier for.
///   - prefix: The prefix to prepend to the identifier (e.g., "Stack" or "Route").
///
/// - Returns: A stable string identifier in the format `<prefix>.<TypeName>.<caseName>[.<associatedValues>]`
///
/// ## Examples
///
/// ```swift
/// // Simple case without associated values
/// generateNavigationIdentifier(for: AppStack.main, prefix: "Stack")
/// // Returns: "Stack.AppStack.main"
///
/// // Case with associated value
/// generateNavigationIdentifier(for: SettingsRoute.profile(id: "abc123"), prefix: "Route")
/// // Returns: "Route.SettingsRoute.profile.abc123"
///
/// // Case with multiple associated values
/// generateNavigationIdentifier(for: DetailRoute.section(name: "intro", page: 5), prefix: "Route")
/// // Returns: "Route.DetailRoute.section.intro.5"
/// ```
internal func generateNavigationIdentifier(
    for value: Any,
    prefix: String
) -> String {
    let mirror = Mirror(reflecting: value)
    let typeName = "\(type(of: value))"

    guard let caseName = mirror.children.first?.label else {
        return "\(prefix).\(typeName).\(value)"
    }

    let associatedValues = mirror.children
        .map { String(describing: $0.value) }
        .joined(separator: ".")

    let baseId = associatedValues.isEmpty ? caseName : "\(caseName).\(associatedValues)"
    return "\(prefix).\(typeName).\(baseId)"
}
