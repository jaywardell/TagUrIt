//
//  ParagraphTag.swift
//  SkyMark Data
//
//  Created by Joseph Wardell on 12/21/24.
//

import Foundation

public struct ParagraphTag: Equatable {
    let content: String
    let attributes: [HTMLAttribute]
    
    func attribute(for key: String) -> HTMLAttribute? {
        attributes.first { $0.name == key }
    }

    static var match: Regex<(Substring, Substring, Substring)> { /<p\s*([^>]*)>(.*?)(?=<\/p>|<p|<\/ p)/.dotMatchesNewlines() }
}

public extension ParagraphTag {
    
    /// if the string passed in contains a html paragraph tag, then return a ParagraphTag instance that contains all its attributes
    static func from(string: String) -> ParagraphTag? {

        guard let found = string.prefixMatch(of: match) else { return nil }
        
        var attributes: [HTMLAttribute] = []
            attributes += HTMLAttribute.all(in: found.1)

        return ParagraphTag(content: String(found.2), attributes: attributes)
    }
    
    /// given a html string, return a ParagraphTag instance for every p tag that can be found
    static func all(in string: String) -> [ParagraphTag] {

        return string.matches(of: match).compactMap { match in
            
            // the regex expects a closing p tag,
            // but uses a lookahead to match
            // so we need to add a synthetic closing </p>
            let newSource = String(match.0) + "</p>"
            return Self.from(string: newSource)
        }
    }
}
