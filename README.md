#  TagURIt

This is a small set of swift types that can be used to pull certain tags from html source.
It's not complete at all.
There are certainly cases that it doesn't cover.

Still, for the purposes of an app like SkyMarks (https://bsky.app/profile/skymarks.bsky.social), it does what is needed.

Right now, this can basically be used to find all paragraph tags in a html string or all meta tags in a html string.

## Example Usage

To find all paragraph tags in a html string, call the `all(in:)` method:

    let paragraphTags = ParagraphTag.all(in: htmlSource)
    
 You will be given an array of ParagraphTag instances from which you can retrieve the content or the attributes.
 
 For instance, here's a method that looks for the first ParagraphTag whose id is the string passed in and returns the content of  
 
     private func getString(for id: String) -> String? {
        
        let tag = paragraphTags.first {
            $0.attribute(for: "id")?.value == id
        }
        guard let tag else { return nil }
        
        return tag.content
    }

Note that the content that is returned is raw html and so it can contain html-encoded elements such as `QUOT;` or `&amp;`
