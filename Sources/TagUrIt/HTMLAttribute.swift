//
//  HTMLAttribute.swift
//  SkyMark Data
//
//  Created by Joseph Wardell on 12/20/24.
//

import Foundation
import RegexBuilder

struct HTMLAttribute: Equatable {
    let name: String
    let value: String
}

extension HTMLAttribute {
    
    static func fromString(_ input: any StringProtocol) -> (found: HTMLAttribute?, remaining: Substring) {
        let string = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !string.isEmpty else { return (nil, Substring(input)) }
        
        guard let pattern = try? Regex(#"([^ \t\n\f<"'=]+)=("([^\t\n\f>"']+)"|([^ \t\n\f>"']+))"#),
              let found = string.prefixMatch(of: pattern)
        else {
            return (nil, Substring(input))
        }
        
        let remainder: Substring =
        if found.range.upperBound >= string.endIndex {
            ""
        }
        else {
            string[found.range.upperBound...]
        }
        
        guard let name = found[1].substring,
              // found[3] matches values with quotation marks
              // found[4] matches values without quotation marks
                let value = (found[3].substring ?? found[4].substring) else {
            
            // this shouldn't actually happen
            // but if it does, we do nothing but pass the remaining on
            return (nil, remainder)
        }
        
        return (HTMLAttribute(name: String(name), value: String(value)), remainder)
    }
    
    static func all(in string: any StringProtocol) -> [HTMLAttribute] {
        var remaining: any StringProtocol = string
        var out = [HTMLAttribute]()
        while !remaining.isEmpty {
            let (attribute, remainder) = Self.fromString(remaining)
            guard let attribute else { break }

            out.append(attribute)
            remaining = remainder
        }
        return out
    }
}
