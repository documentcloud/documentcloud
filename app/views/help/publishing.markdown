# Publishing Documents, Notes, and Document Sets

There are a few ways to publish data from DocumentCloud on your website. You can publish a document by using either a standalone viewer or embedding the document directly onto a page. Additionally, notes from your documents can be embedded directly onto a page. You can also embed an entire set of documents that can be searched through by your readers.

# Publishing Documents on your Website

To publish a document from DocumentCloud on your website, you can either download a standalone copy of the viewer, or copy and paste a simple embed code for that document. The instructions that follow assume some basic familiarity with HTML, but we've tried to keep the embedding process as simple as possible.

For live examples, we're keeping a list of some of our [favorite embedded documents][].  If you've done some great reporting that isn't there yet, [let us know][] about it.

## Step 1: <span id="choose_size">Review your Metadata</span>

![Embed Menu][]

Before you embed a document on your site, we encourage you to fill in a couple of additional pieces of information about the document. Open the document to take one more look over the document's **title**, **description**, **source**, and **public notes**. If everything is as you like it, you're ready to continue.

Select your document, open the "Publish" menu, and click "Embed Document Viewer", or right-click the document, and select "Embed Document Viewer".

A dialog will appear, asking you to fill in two additional pieces of information: the **Related Article URL**, and the **Published URL**. The **Related Article URL** is the location of the article that uses this document as source material &mdash; adding this URL means that readers who find the document first will still find your reporting, too. The **Published URL** is the page where the document is embedded. Most users won't need to provide this &mdash; <a href="http://www.propublica.org/nerds/item/pixel-ping-a-nodejs-stats-tracker">pixel ping</a> can usually tell us where the document is embedded. If a document might be accessed at more than one URL, however, you can specify the URL we should send users to if they find the document through a search of DocumentCloud. 

On step one, you'll also see a checkbox offering to make the document public, if it's not already. While it's possible to paste the embed code before the document is made public, it won't start working until you've published the document on DocumentCloud.

If you're not yet ready to make the document public, you can schedule it to be published at a future date. Click "Set Publication Date" in the "Publish" menu, and choose a date and an hour when you would like the document to be made public. This is useful if you already know when your story is going live, or if your article is running in the middle of the night.

## Step 2: <span id="template">Configure the Document Viewer</span>

Depending on how you wish to display the document on your website, you have two choices: You can create a template for a **full page** viewer, with your own logo, links, analytics and advertising; or you can embed a **fixed size** viewer directly inside an article. You can also embed multiple **fixed size** viewers on a single page.

To create a **full page** template, use a fluid-width layout, with just a header &mdash; the viewer will take up the rest of the page. Make sure that your template has a proper doctype, and passes the [HTML validator][]. Templates that throw Internet Explorer into quirks mode will cause the viewer to display incorrectly.

Here are some live examples worth checking out: [NewsHour][], [Arizona Republic][], [Chicago Tribune][], [ProPublica][], but there are [plenty more][].

<img src="/images/help/newshour.jpg" class="full_line" />

If you choose to make a **fixed size** viewer, set the width and height in pixels. In the embed dialog you can also toggle the sidebar as well as the text tab. We recommend hiding the sidebar in document viewers that are narrower than 800 pixels. If you're embedding handwritten documents or documents with poor OCR results, hiding the text tab is usually a good idea. Use the "preview the document viewer" link to see an example of the viewer rendered to your specifications. 

For a live example of a fixed size document with no sidebar, take a look at [this ballot from WNYC][].

<img src="/images/help/wnyc.jpg" class="full_line" />

## Step 3: <span id="embed">Copy and Paste the Embed Code</span>

Click on the "Next" button to proceed to step 3, and you'll see the embed code: a snippet of HTML that can be pasted into any web page to create a document viewer. The code will look something like this:

    <div id="viewer-10-general-report"></div>
    <script src="http://s3.documentcloud.org/viewer/loader.js"></script>
    <script>
      DV.load('http://www.documentcloud.org/documents/10-general-report.js', {
        container : '#viewer-10-general-report'
      });
    </script>

Place the embed code on your page, in the location where you would like the viewer to appear. The next time you load the page, the viewer should be up and running.
 
## Step 4: <span id="intouch">Stay in Touch</span>

[Let us know][] about your reporting!

# <span id="docset">Embedding a Note from a Document</span>

![Embed Note Menu][]

If you are looking to embed notes directly in your reporting, DocumentCloud can provide the HTML to embed as many notes as you would like. The embedded notes also stay up-to-date with any changes you make to the notes while editing the document.

You can only embed notes from documents that you or your organization owns. You do not have to be the author of the note.

To get started, you can either find a document that contains the note you would like to embed, or go to the note directly and embed it from the document viewer.

To embed a note from the workspace, click on the document, open the "Publish" menu and select "Embed a Note." You'll see a dialog which allows you to choose which note from the document to embed. Here you can preview how the note will look. **Note:** The embedded note will stretch to fill the container it's in. So it may end up wider than the preview. 

If the preview looks good, copy and paste the HTML embed code. Here's an example of what the embed code should look like:

    <div id="DC-note-237"></div>
    <script src="http://s3.documentcloud.org/notes/loader.js"></script>
    <script>
      dc.embed.loadNote('http://www.documentcloud.org/documents/223/annotations/237.js');
    </script>
    
Paste the code into on your website, and you'll see the embedded note appear.

Click on either the note title or the note image to open the document. The document will open directly on the note.

# <span id="docset">Embedding a Document Set</span>

![Embed Search Menu][]

If you'd rather embed a complete set of documents, DocumentCloud can provide the HTML to do that as well. Readers will be able to search or filter through as many documents as you'd like to share with them. 

You can embed any set of documents, whether or not you uploaded them: any document that has already been published by their contributor will open to the URL at which it originally appeared.

To get started, find a set of documents you wish to embed -- either by selecting a project or by running a search. **Note:** future public documents added to the project or matching the search criteria will be added to your embbedded document set. Open the "Publish" menu and select "Embed These Documents." You'll see a dialog which allows you to configure the embedded set:

 * Provide a **title** to be displayed above the embedded set of documents;
 * **Order** documents alphabetically, by date uploaded, or by length;
 * Set the number of documents to display **per page** so that the embedded set suits the height and width of the space you have available; 
 * Hide or reveal a **search bar**, that will allow your readers to search within the embedded set.
 
Once you're comfortable with your settings, preview the embedded document set. If the preview looks good, copy and paste the HTML embed code. Here's an example of what the embed code should look like:

    <div id="DC-search-projectid-8-epa-flouride"></div>
    <script src="http://s3.documentcloud.org/embed/loader.js"></script>
    <script>
      dc.embed.load('http://www.documentcloud.org/search/embed/', {
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

Still have questions about publishing documents? Don't hesitate to [contact us][].

[Embed Menu]: /images/help/embed_menu.png
[Embed Note Menu]: /images/help/embed_note_menu.png
[Embed Search Menu]: /images/help/embed_search_menu.png
[favorite embedded documents]: /featured
[terms and conditions]: /terms
[plenty more]: /featured
[HTML validator]: http://validator.w3.org/
[NewsHour]: http://www.pbs.org/newshour/rundown/stevens-testimony.html
[Arizona Republic]: http://www.azdatapages.com/sb1070.html
[Chicago Tribune]: http://media.apps.chicagotribune.com/docs/obama-subpoena.html
[ProPublica]: http://www.propublica.org/documents/item/magnetars-responses-to-our-questions
[this document from the Commercial Appeal]: http://www.commercialappeal.com/data/documents/bass-pro-lease/
[this ballot from WNYC]: http://beta.wnyc.org/articles/its-free-country/2010/sep/07/new-nyc-ballot-could-cause-confusion/
[contact us]: javascript:dc.ui.Dialog.contact()
