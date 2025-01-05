//
//  MetaTagTests.swift
//  SkyMark Data Tests
//
//  Created by Joseph Wardell on 12/20/24.
//

import Testing
@testable import TagUrIt

struct MetaTagTests {

    struct fromstring {
        @Test func returns_nil_for_empty_string() async throws {
            #expect(nil == MetaTag.from(string: ""))
        }
        
        @Test func returns_nil_for_just_a_word() async throws {
            #expect(nil == MetaTag.from(string: "cars"))
        }

        @Test func returns_nil_for_other_html_tag() async throws {
            #expect(nil == MetaTag.from(string: "<br />"))
        }

        @Test func returns_empty_tag_for_empty_attributes() async throws {
            let string = "<meta />"
            let tag = MetaTag.from(string: string)
            #expect(nil != tag)
            #expect(true == tag?.attributes.isEmpty)
        }

        @Test func returns_all_attributes_for_tag_that_has_them() async throws {
            let string = #"<meta property="og:title" content="some title" />"#
            let expected = [
                HTMLAttribute(name: "property", value: "og:title"),
                HTMLAttribute(name: "content", value: "some title"),
            ]
            
            let tag = MetaTag.from(string: string)
            #expect(expected == tag?.attributes)
        }
    }
    
    struct all_in {
        @Test func returns_empty_if_given_empty_string() async throws {
            #expect([] == MetaTag.all(in: ""))
        }

        @Test func returns_one_if_one_found() async throws {
            let string = #"<meta property="og:title" content="some title" />"#
            let expected = [
                MetaTag(attributes: [
                    HTMLAttribute(name: "property", value: "og:title"),
                    HTMLAttribute(name: "content", value: "some title"),
                ])
                
            ]
            #expect(expected == MetaTag.all(in: string))
        }

        @Test func returns_all_found() async throws {
            let string = """
            <meta property="og:type" content="some type" />
            <meta property="og:title" content="some title" />
            <meta property="og:url" content="invalid" />
            """
            let expected = [
                MetaTag(attributes: [
                    HTMLAttribute(name: "property", value: "og:type"),
                    HTMLAttribute(name: "content", value: "some type"),
                ]),
                MetaTag(attributes: [
                    HTMLAttribute(name: "property", value: "og:title"),
                    HTMLAttribute(name: "content", value: "some title"),
                ]),
                MetaTag(attributes: [
                    HTMLAttribute(name: "property", value: "og:url"),
                    HTMLAttribute(name: "content", value: "invalid"),
                ])

            ]
            
            let alltags = MetaTag.all(in: string)
            #expect(expected == alltags)
            #expect(expected.count == alltags.count)
        }
    }

    @Test func returns_all_found_ignoring_other_text() async throws {
        let string = """
        <head>
        <meta property="og:type" content="some type" />
        <title>Hello</title>
        <meta property="og:title" content="some title" />
        <meta property="og:url" content="invalid" />
        </head>
        <body>
        <H1>Hello</H1>
        </body>
        """
        let expected = [
            MetaTag(attributes: [
                HTMLAttribute(name: "property", value: "og:type"),
                HTMLAttribute(name: "content", value: "some type"),
            ]),
            MetaTag(attributes: [
                HTMLAttribute(name: "property", value: "og:title"),
                HTMLAttribute(name: "content", value: "some title"),
            ]),
            MetaTag(attributes: [
                HTMLAttribute(name: "property", value: "og:url"),
                HTMLAttribute(name: "content", value: "invalid"),
            ])

        ]
        
        let alltags = MetaTag.all(in: string)
        #expect(expected == alltags)
        #expect(expected.count == alltags.count)
    }
    
    struct attribute {
        @Test func returns_nil_if_no_attribute_with_given_name() async throws {
            let sut = MetaTag(attributes: [])
            #expect(nil == sut.attribute(for: "key"))
        }
        
        @Test func returns_value_of_attribute_whose_name_matches_key() async throws {
            let sut = MetaTag(attributes: [
                HTMLAttribute(name: "content", value: "some title"),
                HTMLAttribute(name: "property", value: "title")
            ])
            #expect(sut.attribute(for: "property")?.value == "title")
        }

        @Test func returns_first_attribute_if_more_than_one_match() async throws {
            let sut = MetaTag(attributes: [
                HTMLAttribute(name: "property", value: "title"),
                HTMLAttribute(name: "property", value: "title2"),
                HTMLAttribute(name: "property", value: "title3")
            ])
            #expect(sut.attribute(for: "property")?.value == "title")
        }

    }

}
