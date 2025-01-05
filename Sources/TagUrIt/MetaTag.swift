//
//  MetaTag.swift
//  SkyMark Data
//
//  Created by Joseph Wardell on 12/20/24.
//

import Foundation

public struct MetaTag: Equatable {
    let attributes: [HTMLAttribute]
    
    func attribute(for key: String) -> HTMLAttribute? {
        attributes.first { $0.name == key }
    }
    
    static var regex: Regex<(Substring, Substring)> { /<meta\s+(.+?)\s*\/*>/ }
}

public extension MetaTag {
    
    /// if the string passed in contains a html meta tag, then return a MetaTag instance that contains all its attributes
    static func from(string: String) -> MetaTag? {

        guard let found = string.prefixMatch(of: regex) else { return nil }
        
        var attributes: [HTMLAttribute] = []
        attributes += HTMLAttribute.all(in: found.1)

        return MetaTag(attributes: attributes)
    }
    
    /// given a html string, return a MetaTag instance for every meta tag that can be found
    static func all(in string: String) -> [MetaTag] {

        return string.matches(of: regex).compactMap { match in
            return Self.from(string: String(match.0))
        }
    }
}
