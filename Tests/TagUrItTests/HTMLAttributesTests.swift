//
//  HTMLAttributesTests.swift
//  SkyMark Data Tests
//
//  Created by Joseph Wardell on 12/20/24.
//

import Testing

@testable import TagUrIt

struct HTMLAttributesTests {
    
    struct fromString_found {
        @Test func returns_nil_for_empty_string() async throws {
            #expect(nil == HTMLAttribute.fromString("").0)
        }
        
        @Test func returns_nil_for_single_word() async throws {
            #expect(nil == HTMLAttribute.fromString("content").0)
        }
        
        @Test func pullsValuesFromString() async throws {
            let string = #"content="hello""#
            let att = HTMLAttribute.fromString(string).0
            #expect(att?.name == "content")
            #expect(att?.value == "hello")
        }
        
        @Test func ignroes_whitespace_before_or_after() async throws {
            let string = #" content="hello""#
            let att = HTMLAttribute.fromString(string).0
            #expect(att?.name == "content")
            #expect(att?.value == "hello")
        }
        
        @Test func returns_nil_if_spaces_besideEqualSign() async throws {
            let string = #"content = "hello""#
            let att = HTMLAttribute.fromString(string).0
            #expect(nil == att)
        }

        @Test func pullsValuesFromStringWithNoQuoteAroundContent() async throws {
            let string = #"width=415"#
            let att = HTMLAttribute.fromString(string).0
            #expect(att?.name == "width")
            #expect(att?.value == "415")
        }
        
        @Test func returns_nil_if_only_one_quotation_mark() async throws {
            let missingquoteaftervalue = #"width="415"#
            #expect(nil == HTMLAttribute.fromString(missingquoteaftervalue).0)
        }

        @Test func other_example() async throws {
            let string = #"property="og:title""#
            let att = HTMLAttribute.fromString(string).0
            #expect(att?.name == "property")
            #expect(att?.value == "og:title")
        }

        @Test func other_other_example() async throws {
            let string = #"content="some title""#
            let att = HTMLAttribute.fromString(string).0
            #expect(att?.name == "content")
            #expect(att?.value == "some title")
        }

        @Test func example_with_dot_in_value() async throws {
            let string = #"content="video.movie""#
            let att = HTMLAttribute.fromString(string).0
            #expect(att?.name == "content")
            #expect(att?.value == "video.movie")
        }

        @Test func example_with_long_url() async throws {
            let string = #"content="https://images.macrumors.com/t/-x54PV1I_yMyszOcetNRKKyTwUU=/2500x/article-new/2024/12/TMRS-Flip-iPhone-and-ShowPod-Thumb-2.jpg""#
            let att = HTMLAttribute.fromString(string).0
            #expect(att?.name == "content")
            #expect(att?.value == "https://images.macrumors.com/t/-x54PV1I_yMyszOcetNRKKyTwUU=/2500x/article-new/2024/12/TMRS-Flip-iPhone-and-ShowPod-Thumb-2.jpg")
        }

        @Test func example_with_stubborn_title() async throws {
            let string = #"content="Kara Swisher Wants to Take WaPo Off Jeff Bezos’ Hands""#
            let att = HTMLAttribute.fromString(string).0
            #expect(att?.name == "content")
            #expect(att?.value == "Kara Swisher Wants to Take WaPo Off Jeff Bezos’ Hands")
        }

        @Test func example_with_stubborn_title2() async throws {
            let string = #"content="Mia Farrow Slams RFK Jr. With Harrowing Photos Of Polio&#39;s Toll Before The Vaccine""#
            let att = HTMLAttribute.fromString(string).0
            #expect(att?.name == "content")
            #expect(att?.value == "Mia Farrow Slams RFK Jr. With Harrowing Photos Of Polio&#39;s Toll Before The Vaccine")
        }

    }
    
    struct fromString_remaining {
        @Test
        func retruns_empty_string_if_empty() async throws {
            #expect("" == HTMLAttribute.fromString("").1)
        }
        
        @Test
        func retruns_empty_string_if_no_content_after_attribute() async throws {
            let string = #"content="hello""#
            let remaining = HTMLAttribute.fromString(string).1
            #expect("" == remaining)
        }
        
        @Test
        func retruns_remainder_if_there_is_more_text() async throws {
            let string = #"content="hello" hello"#
            let remaining = HTMLAttribute.fromString(string).1
            #expect(" hello" == remaining)
        }
        
       @Test
        func retruns_remainder_if_there_is_more_text_after_no_quote_attribute() async throws {
            let string = #"width=415    hello"#
            let remaining = HTMLAttribute.fromString(string).1
            #expect("    hello" == remaining)
        }
    }
    
    struct attributesFromString {
        @Test func returns_empty_for_empty_string() async throws {
            #expect([] == HTMLAttribute.all(in: ""))
        }

        @Test func returns_one_attribute_if_given_one_attribute() async throws {
            let string = #"name="value""#
            #expect([HTMLAttribute(name: "name", value: "value")] == HTMLAttribute.all(in: string))
        }

        @Test func returns_all_attributes_without_quotes() async throws {
            let string = #"width=415 height=500"#
            let expected = [
                HTMLAttribute(name: "width", value: "415"),
                HTMLAttribute(name: "height", value: "500")
            ]
            
            let found = HTMLAttribute.all(in: string)
            
            #expect(expected == found)
            #expect(expected.count == found.count)
        }

        @Test func returns_all_attributes() async throws {
            let string = #"name="value" width=415 height=500"#
            let expected = [
                HTMLAttribute(name: "name", value: "value"),
                HTMLAttribute(name: "width", value: "415"),
                HTMLAttribute(name: "height", value: "500")
            ]
            
            let found = HTMLAttribute.all(in: string)
            
            #expect(expected == found)
            #expect(expected.count == found.count)
        }

        @Test func respects_whitespace() async throws {
            let string = #"name="value"      width=415   height=500"#
            let expected = [
                HTMLAttribute(name: "name", value: "value"),
                HTMLAttribute(name: "width", value: "415"),
                HTMLAttribute(name: "height", value: "500")
            ]
            
            let found = HTMLAttribute.all(in: string)
            
            #expect(expected == found)
            #expect(expected.count == found.count)
        }
        
        @Test func stops_at_tab() async throws {
            let string = #"name="value"      width=415  \t height=500"#
            let expected = [
                HTMLAttribute(name: "name", value: "value"),
                HTMLAttribute(name: "width", value: "415"),
                HTMLAttribute(name: "height", value: "500")
            ]
            
            let found = HTMLAttribute.all(in: string)
            
            #expect(expected != found)
            #expect(expected.count - 1 == found.count)
        }
    }
}
