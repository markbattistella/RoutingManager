//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// Defines the requirements for an object that can save and load navigation path data.
public protocol NavigationPathStorage {
    
    /// Saves navigation data to a specified location.
    ///
    /// - Parameters:
    ///   - data: The `Data` object to be saved.
    ///   - identifier: An optional string used to identify the save location or filename.
    /// - Throws: An error if the data could not be saved.
    func save(data: Data, identifier: String?) throws
    
    /// Loads navigation data from a specified location.
    ///
    /// - Parameter identifier: An optional string used to identify the load location or filename.
    /// - Returns: The `Data` object loaded from the specified location.
    /// - Throws: An error if the data could not be loaded.
    func load(identifier: String?) throws -> Data
}

public extension NavigationPathStorage {
    
    /// Saves navigation data to a default location.
    ///
    /// - Parameters:
    ///   - data: The `Data` object to be saved.
    /// - Throws: An error if the data could not be saved.
    func saveToDefaultLocation(data: Data) throws {
        try save(data: data, identifier: nil)
    }
    
    /// Loads navigation data from a default location.
    ///
    /// - Returns: The `Data` object loaded from the default location.
    /// - Throws: An error if the data could not be loaded.
    func loadFromDefaultLocation() throws -> Data {
        return try load(identifier: nil)
    }
}
