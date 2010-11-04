# Publishing Documents on your Web Site

To publish a document from DocumentCloud on your website, you can either download a standalone copy of the viewer, or copy and paste a simple embed code for that document. The instructions that follow assume some basic familiarity with HTML, but we've tried to keep the embedding process as simple as possible.

For live examples, we're keeping a list of some of our [favorite embedded documents][].  If you've done some great reporting that isn't there yet, [let us know][] about it.
 
## Caveats

First, a note about public documents. Right now, no one can see your "public" documents unless they're a registered user who is part of our beta. Soon, we'll be opening the archive to the general public, and "public" documents will be available to anyone who searches for them.

DocumentCloud is still actively in beta. That means a lot of things, but when it comes to embedding documents it means this: First, you are reliant on our servers: If our servers go down your document goes down. You can host documents yourself, but you'll miss out on bug fixes, and will have to manually upgrade to newer versions of the viewer. Second, we can't make any promises. We test our work well, but we are actively working on this software and are as vulnerable to hosting glitches as anyone else. Take a look at our [terms and conditions][] for a fuller disclaimer of liability.

## Step 1: <span id="choose_size">Review your Metadata</span>

![Embed Menu][]

Before you embed a document on your site, we encourage you to fill in a couple of additional pieces of information about the document. Open the document to take one more look over the document's **title**, **description**, **source**, and **public notes**. If everything is as you like it, you're ready to continue.

Select your document, open the "Publish" menu, and click "Embed Document Viewer", or right-click the document, and select "Embed Document Viewer".

A dialog will appear, asking you to fill in two additional pieces of information: the **Related Article URL**, and the **Document URL**. The **Related Article URL** is the location of the article you've written that uses the document as source material. The **Document URL** is the location of the page on your website where the document will be embedded. If you know both URLs at this time, please enter them &mdash; if you don't, remember to come back and add them once the document has been published.

On step one, you'll also see a checkbox offering to make the document public, if it's not already. It's possible to test the embed code with a private document, but you have to make it public before your readers will be able to see it. For large documents, the process of making the document public may take a couple of minutes.
 
*Note: once you change a document to "public" other users of DocumentCloud will be able to find it in searches of the repository. Don't make sensitive documents public in advance of publication.*

## Step 2: <span id="template">Configure the Document Viewer</span>

Depending on how you wish to display the document on your website, you have two choices: You can create a template for a **Full Page** viewer, with your own logo, links, analytics, and advertising; or you can embed a **Fixed Size** viewer directly inside an article, or place multiple **Fixed Size** viewers on a single page.

To create a **Full Page** template, use a fluid-width layout, with just a header &mdash; the viewer will take up the rest of the page. Make sure that your template has a proper doctype, and passes the [HTML validator][]. Templates that throw Internet Explorer into quirks mode will cause the viewer to display incorrectly.

Here are some live examples worth checking out: [NewsHour][], [Arizona Republic][], [Chicago Tribune][], [ProPublica][], but there are [plenty more][].

<img src="/images/help/newshour.jpg" class="full_line" />

If you choose to make a **Fixed Size** viewer, set the width and height in pixels. Click on the "preview the document viewer" link, and you'll see an example of the viewer rendered at your specified size. If there's not enough space to show the sidebar (usually anything less than 800 pixels wide), click the checkbox to turn the sidebar off, and preview the document again.

For a live example of this type of embed, take a look at [this ballot from WNYC][].

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
