# Publishing Documents, Pages, Notes, and Document Sets

Ready to share your documents with readers? Either by embedding our custom viewer or using oEmbed, you can publish individual documents, embed a set of documents that readers can browse, or embed a single page or note from any document.

## Contents

* [Making documents public](#public)
* [Linking to a Document, Page or Note](#linking)
* Generating embed codes:
  * [Documents](#embed-document)
  * [Pages](#embed-page)
  * [Notes](#embed-note)
  * [Document Lists](#embed-list)
* [WordPress Shortcodes](#wordpress)
* [oEmbed service](#oembed)

<a name="public"></a>
# Making Documents Public

Before you publish a document, page, note or document set, you'll want to make sure that the document or documents are public. There are two ways to do this:

* Edit the "Access Level" (from the "Edit" menu).
* Set a publication date (from the "Publish" menu).

<a name="linking"></a>
# Linking to a Document, Page or Note</span>

The most simple way to share your work in DocumentCloud with readers is to publish a URL to a document. You can modify the URL to have the document open to a specific page or note. Follow these URL formats:

### Full document:

`https://www.documentcloud.org/documents/282753-lefler-thesis.html`

### Document open to a specific page:

`https://www.documentcloud.org/documents/282753-lefler-thesis.html#document/p22`

### Document open to a specific note:

`https://www.documentcloud.org/documents/282753-lefler-thesis.html#document/p57/a42283`

To find the URL (or permalink) of a note, open the note and select the link icon <span class="icon permalink" style="padding-left:16px;position:relative;top: -2px;">&#65279;</span>. Your browser's address bar will be updated to display the full URL of the annotation.

<a name="embed-document"></a>
# Embed Codes for Individual Documents

To publish any document from DocumentCloud, either download a standalone copy of the viewer, or generate, copy, and paste a simple embed code for that document. We strongly encourage you to embed code that links back to DocumentCloud for most documents. The instructions that follow assume some basic familiarity with HTML, but we've tried to keep the embedding process as simple as possible.

We maintain a list of some of our [favorite embedded documents][] as examples of how newsrooms might embed documents.

## <span id="choose_size">Review your Metadata</span>

![Embed Menu][]

Before you embed a document on your site, we encourage you to fill in a couple of additional pieces of information about the document. Open the document to take one more look over the document's **title**, **description**, **source**, and **public notes**. If everything is as you like it, you're ready to continue.

Select a document, open the "Publish" menu and click "Embed Document Viewer." Alternately, right-click the document and select "Embed Document Viewer."

A dialog will appear, asking you to fill in two additional pieces of information: the **Related Article URL** and the **Published URL**. The **Related Article URL** is the location of the article that uses this document as source material &mdash; adding this URL means that readers who find the document first will still find your reporting, too. The **Published URL** is the page where the document is embedded. Most users won't need to provide this &mdash; [pixel ping](http://www.propublica.org/nerds/item/pixel-ping-a-nodejs-stats-tracker) can usually tell us where the document is embedded. If a document might be accessed at more than one URL, however, you can specify the URL we should send users to if they find the document through a search of DocumentCloud.

On step one, you'll also see a checkbox offering to make the document public, if it's not already. While it's possible to paste the embed code before the document is made public, it won't start working until you've published the document on DocumentCloud.

If you're not ready to make the document public, you can schedule it to be published at a future date. Click "Set Publication Date" in the "Publish" menu and choose a date and an hour when you would like the document to be made public. This is useful if you know when your story is going live, or if your story is running in the middle of the night.

## <span id="template">Configure the Document Viewer</span>

Depending on how you wish to display the document, you have two choices: You can create a template for a **full page** viewer, with your own logo, links, analytics and advertising; or you can embed a **fixed size** viewer directly inside an article. You can also embed multiple **fixed size** viewers on a single page.

To create a **full page** template, use a fluid-width layout with just a header &mdash; the viewer will take up the rest of the page. Make sure that your template has a proper doctype and passes the [HTML validator][]. Templates that throw Internet Explorer into quirks mode will cause the viewer to display incorrectly.

Live examples worth checking out are at the [Chicago Tribune][] and [ProPublica][], but there are [plenty more][].

<img src="/images/help/newshour.jpg" class="full_line" />

If you opt to embed a **fixed size** viewer, set the width and height in pixels. Both the sidebar and the text tab can be shown or not. We recommend hiding the sidebar in document viewers that are narrower than 800 pixels. If you're embedding handwritten documents or documents with poor OCR results, hiding the text tab is usually a good idea. Use the "preview the document viewer" link to see an example of the viewer rendered to your specifications.

## <span id="embed">Copy and Paste the Code</span>

Click on the "Next" button to proceed to step 3, and you'll see the embed code: a snippet of HTML that can be pasted into any web page to create a document viewer. The code will look something like this:

    <div id="viewer-10-general-report"></div>
    <script src="//assets.documentcloud.org/viewer/loader.js"></script>
    <script>
      DV.load('https://www.documentcloud.org/documents/10-general-report.js', {
        container : '#viewer-10-general-report'
      });
    </script>

Place the embed code on your page, in the location where you would like the viewer to appear. The next time you load the page, the viewer should be up and running.

## <span id="intouch">Stay in Touch</span>

[Let us know][] about your reporting!

<a name="embed-page"></a>
# <span id="page_embed">Embed Codes for a Single Page</span>

![Embed Page Menu][]

DocumentCloud offers a lightweight, responsive viewer that highlights a single page (including your annotations) with minimal extra chrome. It's designed to work equally well on mobile and desktop and is perfect for use in custom news applications or on long-form journalism presentations. Coming soon: options to allow readers to access all the pages in the document or read the extracted text.

Embedding a page is similar to embedding a document: Select a document, open the "Publish" menu and click "Embed a Page." Alternately, right-click the document and select "Embed a Page."

In the dialog box that appears next, select the number of the page to embed. A preview of the page embed appears; if you want a different page, you can select it from the menu.

Click "Next" to move to Step 2 and generate the HTML embed code. Here is a sample of what it will look like:

    <div class="DC-embed" data-version="1.1">
      <div style="font-size:10pt;line-height:14pt;">
        Page 57 of <a class="DC-embed-resource" href="https://www.documentcloud.org/documents/282753-lefler-thesis.html#document/p57" title="View entire Lefler Thesis on DocumentCloud in new window or tab" target="_blank">Lefler Thesis</a>
      </div>
      <img src="//www.documentcloud.org/documents/282753/pages/lefler-thesis-p57-normal.gif" srcset="//www.documentcloud.org/documents/282753/pages/lefler-thesis-p57-normal.gif 700w, //www.documentcloud.org/documents/282753/pages/lefler-thesis-p57-large.gif 1000w" alt="Page 57 of Lefler Thesis" style="max-width:100%;height:auto;margin:0.5em 0;border:1px solid #ccc;-webkit-box-sizing:border-box;box-sizing:border-box;clear:both">
      <div style="font-size:8pt;line-height:12pt;text-align:center">
        Contributed to
        <a href="https://www.documentcloud.org/" title="Go to DocumentCloud in new window or tab" target="_blank" style="font-weight:700;font-family:Gotham,inherit,sans-serif;color:inherit;text-decoration:none">DocumentCloud</a> by
        <a href="https://www.documentcloud.org/public/search/Account:2258-ted-han" title="View documents contributed to DocumentCloud by Ted Han in new window or tab" target="_blank">Ted Han</a> of
        <a href="https://www.documentcloud.org/public/search/Group:dcloud" title="View documents contributed to DocumentCloud by DocumentCloud in new window or tab" target="_blank">DocumentCloud</a> &bull;
        <a href="https://www.documentcloud.org/documents/282753-lefler-thesis.html#document/p57" title="View entire Lefler Thesis on DocumentCloud in new window or tab" target="_blank">View document</a> or
        <a href="https://www.documentcloud.org/documents/282753/pages/lefler-thesis-p57.txt" title="Read the text of page 57 of Lefler Thesis on DocumentCloud in new window or tab" target="_blank">read text</a>
      </div>
    </div>
    <script src="//assets.documentcloud.org/embed/loader/enhance.js"></script>

Copy and paste the HTML to your site to publish the page.

<a name="embed-note"></a>
# <span id="note_embed">Embed Codes for a Note in a Document</span>

![Embed Note Menu][]

If you have [annotated a document](/help/notes), you can embed any note directly on your site. Users can embed notes from any document for which you have edit privileges. To embed a note, select any document and then choose "Embed a Note" from the "Publish" menu.

You'll be asked to select the note to embed, and will be able to preview the embedded note. Use your own CSS to control the width of any note on your site. Your HTML embed code will look something like this:

    <div id="DC-note-237"></div>
    <script src="//assets.documentcloud.org/notes/loader.js"></script>
    <script>
      dc.embed.loadNote('https://www.documentcloud.org/documents/223/annotations/237.js');
    </script>

Copy and paste the HTML onto your own site. Clicking the title or the image will open the document. Documents will open in DocumentCloud unless you've published them elsewhere. We use [pixel ping](http://www.propublica.org/nerds/item/pixel-ping-a-nodejs-stats-tracker) to guess a document's Published URL, so if users won't find the document another way, you may need to add the Published URL manually.

<a name="embed-list"></a>
# <span id="docset">Embed Codes for a Document List</span>

![Embed Search Menu][]

If you'd rather embed a collection of documents, DocumentCloud can provide the HTML to do that as well. Readers will be able to search or filter through as many documents as you'd like to share with them.

You can embed any set of documents, whether or not you uploaded them: any document that has already been published by its contributor will open to the URL at which it originally appeared.

To get started, find a set of documents you wish to embed -- either by selecting a project or by running a search. **Note:** Future public documents added to the project or matching the search criteria will be added to your embedded document set. Open the "Publish" menu and select "Embed Document List." You'll see a dialog which allows you to configure the embedded set:

 * Provide a **title** to be displayed above the embedded set of documents;
 * **Order** documents alphabetically, by date uploaded, or by length;
 * Set the number of documents to display **per page** so that the embedded set suits the height and width of the space you have available;
 * Hide or reveal a **search bar** that will allow your readers to search within the embedded set.

Once you're comfortable with your settings, preview the embedded document set. If the preview looks good, copy and paste the HTML embed code. Here's an example of what the embed code should look like:

    <div id="DC-search-projectid-8-epa-flouride"></div>
    <script src="//assets.documentcloud.org/embed/loader.js"></script>
    <script>
      dc.embed.load('https://www.documentcloud.org/search/embed/', {
        q: "projectid: 8-epa-flouride",
        container: "#DC-search-projectid-8-epa-flouride",
        order: "title",
        per_page: 12,
        search_bar: true,
        organization: 117
      });
    </script>

Paste the code into on your website, and you'll see the set of documents appear.

<img src="/images/help/search_embed.png" class="full_line" />

Click on any document to open it. If you've previously published the document on your website, we should have automatically detected its URL, and it will open at that URL. If the document is public but has not yet been published, it will open on DocumentCloud.org. If you're sure that you've published a document but it still opens on DocumentCloud.org, open the "Edit" menu, click "Published URL", and manually set the URL at which the document has been published.

<a name="wordpress"></a>
# <span id="docset">WordPress Shortcodes</span>

Users who publish via WordPress can install a plugin that lets you embed DocumentCloud resources using [shortcodes](https://codex.wordpress.org/Shortcode_API).

Download the DocumentCloud plugin at its [WordPress plugin page](https://wordpress.org/plugins/documentcloud/). Install and activate it according to the directions.

Once activated, you can embed resources with a simple shortcode, which you can grab from the last step of our embed wizard. You also can pass additional parameters to control the size and attributes of the embed.

For example, if you want to embed a document at 800px wide, pre-scrolled to page 3:

    [documentcloud url="https://www.documentcloud.org/documents/282753-lefler-thesis.html" width="800" default_page="3"]

If you don't indicate a width (or manually disable responsive widths with `responsive="false"`), then the document will automatically narrow and widen to fill available width.

For a page, use any page-specific URL:

    [documentcloud url="https://www.documentcloud.org/documents/282753-lefler-thesis.html#document/p22"]

For a note, use any note-specific URL:

    [documentcloud url="https://www.documentcloud.org/documents/282753-lefler-thesis.html#document/p1/a53674"]

A list of all the parameters you can use with the shortcode is available on the [plugin page](https://wordpress.org/plugins/documentcloud/).

<a name="oembed"></a>
# <span id="docset">oEmbed Service</span>

oEmbed is a Web standard for providing embedded content on a site via a request to the URL of the resource. If a content management system supports oEmbed, you can simply paste in the URL to a DocumentCloud resource, and the CMS will fetch it via our [oEmbed API][] and embed it. Check with your organization's systems administrator about whether your CMS supports oEmbed.

### Example document URL for oEmbed

    https://www.documentcloud.org/documents/1234-document-name.html

### Example page URL for oEmbed

    https://www.documentcloud.org/documents/1234-document-name/pages/2.html

### Example note URL for oEmbed

    https://www.documentcloud.org/documents/1234-document-name/annotations/220666.html

# Questions?

Still have questions about publishing and embedding? Don't hesitate to [contact us][].

[Embed Menu]: /images/help/embed_menu.png
[Embed Page Menu]: /images/help/embed_page_menu.png
[Embed Note Menu]: /images/help/embed_note_menu.png
[Embed Search Menu]: /images/help/embed_search_menu.png
[favorite embedded documents]: /featured
[terms and conditions]: /terms
[plenty more]: /featured
[HTML validator]: http://validator.w3.org/
[Chicago Tribune]: http://media.apps.chicagotribune.com/docs/obama-subpoena.html
[ProPublica]: http://www.propublica.org/documents/item/magnetars-responses-to-our-questions
[this document from the Commercial Appeal]: http://www.commercialappeal.com/data/documents/bass-pro-lease/
[oEmbed API]: https://www.documentcloud.org/help/api#oembed
[contact us]: javascript:dc.ui.Dialog.contact()
