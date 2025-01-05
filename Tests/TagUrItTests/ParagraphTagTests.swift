//
//  ParagraphTagTests.swift
//  SkyMark Data Tests
//
//  Created by Joseph Wardell on 12/29/24.
//

import Testing

@testable import TagUrIt

struct ParagraphTagTests {

    struct fromstring {
        @Test func returns_nil_for_empty_string() async throws {
            #expect(nil == ParagraphTag.from(string: ""))
        }
        
        @Test func returns_nil_for_just_a_word() async throws {
            #expect(nil == ParagraphTag.from(string: "cars"))
        }

        @Test func returns_nil_for_other_html_tag() async throws {
            #expect(nil == ParagraphTag.from(string: "<br />"))
        }

        @Test func returns_empty_attributes_if_given_no_attributes() async throws {
            let string = "<p></p>"
            let unwrapped = try #require(ParagraphTag.from(string: string))
            #expect(unwrapped.attributes.isEmpty)
        }

        @Test func returns_all_attributes_for_tag_that_has_them() async throws {
            let string = #"<p id="first" class="fancy"></p>"#
            let expected = [
                HTMLAttribute(name: "id", value: "first"),
                HTMLAttribute(name: "class", value: "fancy"),
            ]
            
            let tag = ParagraphTag.from(string: string)
            #expect(expected == tag?.attributes)
        }
        
        @Test func returns_content_for_tag_that_has_it() async throws {
            let expected = "some text"
            let string = "<p>\(expected)</p>"
            
            let tag = ParagraphTag.from(string: string)
            #expect(expected == tag?.content)
        }

        @Test func returns_empty_content_for_tag_that_has_no_content() async throws {
            let string = "<p></p>"
            
            let unwrapped = try #require(ParagraphTag.from(string: string))
            #expect(unwrapped.content.isEmpty)
        }

        @Test func returns_multiline_content() async throws {
            let expected = """
            My little buttercup
            has the sweeetest smile.
            Dear little buttercup
            won't you stay a while
            """
            let string = "<p>\(expected)</p>"
            
            let unwrapped = try #require(ParagraphTag.from(string: string))
            #expect(unwrapped.content == expected)
        }

    }
    
    struct all_in {
        @Test func returns_empty_if_given_empty_string() async throws {
            #expect([] == ParagraphTag.all(in: ""))
        }
        
        @Test func returns_one_if_one_found() async throws {
            let string = #"<p></p>"#
            let expected = [
                ParagraphTag(content: "", attributes: [])
            ]
            #expect(expected == ParagraphTag.all(in: string))
        }

        @Test func returns_all_found() async throws {
            let string = """
            <p>some text</ p>
            <p></p>
            <p>some <b>bold</b> text</ p>
            <p>some <b>bold</b> and some <i>italix</i> text</ p>
            <p lang="en">some text</p>
            """
            let expected = [
                ParagraphTag(content: "some text", attributes: []),
                ParagraphTag(content: "", attributes: []),
                ParagraphTag(content: "some <b>bold</b> text", attributes: []),
                ParagraphTag(content: "some <b>bold</b> and some <i>italix</i> text", attributes: []),
                ParagraphTag(content: "some text", attributes: [.init(name: "lang", value: "en")]),
            ]
            
            let alltags = try #require(ParagraphTag.all(in: string))
            #expect(expected == alltags)
        }

        @Test func returns_all_found_ignoring_other_text() async throws {
            let string = """
            <html>
            <head>
            </head>
            <body>
            <p>some text</ p>
            <p></p>
            <p>some <b>bold</b> text</ p>
            <p>some <b>bold</b> and some <i>italix</i> text</ p>
            <p lang="en">some text</p>
            </body>
            </html>
            """
            let expected = [
                ParagraphTag(content: "some text", attributes: []),
                ParagraphTag(content: "", attributes: []),
                ParagraphTag(content: "some <b>bold</b> text", attributes: []),
                ParagraphTag(content: "some <b>bold</b> and some <i>italix</i> text", attributes: []),
                ParagraphTag(content: "some text", attributes: [.init(name: "lang", value: "en")]),
            ]
            
            let alltags = try #require(ParagraphTag.all(in: string))
            #expect(expected == alltags)
        }

        // we had a bug where if the input was a paragraph tag with not centent
        // the output's content would be the paragraph's closing tag
        @Test func respects_empty_content() async throws {
            let string = """
            <p lang="en">some text</p>
            <p lang="en"></p>
            <p lang="en">some text</p>
            """
            let expected = ParagraphTag(content: "", attributes: [.init(name: "lang", value: "en")])

            
            let alltags = try #require(ParagraphTag.all(in: string))
            #expect(expected == alltags[1])
        }

    }

}
