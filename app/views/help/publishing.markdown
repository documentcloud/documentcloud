# Publishing Documents on your Web Site

To publish a document from DocumentCloud on your website, you can either download a standalone copy of the viewer, or copy and paste a simple embed code for that document. The instructions that follow assume some basic familiarity with HTML, but we've tried to keep the embedding process as simple as possible.

For live examples, we're keeping a list of some of our [favorite embedded documents][].  If you've done some great reporting that isn't there yet, [let us know][] about it.

## Step 1: <span id="choose_size">Review your Metadata</span>

![Embed Menu][]

Before you embed a document on your site, we encourage you to fill in a couple of additional pieces of information about the document. Open the document to take one more look over the document's **title**, **description**, **source**, and **public notes**. If everything is as you like it, you're ready to continue.

Select your document, open the "Publish" menu, and click "Embed Document Viewer", or right-click the document, and select "Embed Document Viewer".

A dialog will appear, asking you to fill in two additional pieces of information: the **Related Article URL**, and the **Published URL**. The **Related Article URL** is the location of the article you've written that uses the document as source material. The **Published URL** is the location of the page on your website where the document will be embedded. If you know both URLs at this time, please enter them &mdash; if you don't, remember to come back and add them once the document has been published.

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

[Let us know][] about your reporting. Even if it is "just a little local story" -- we're interested in all the reporting you do with DocumentCloud.

Still have questions about publishing documents? Don't hesitate to [contact us][].

[Embed Menu]: /images/help/embed_menu.png
[favorite embedded documents]: http://documentcloud.pbworks.com/Document-Dives
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
