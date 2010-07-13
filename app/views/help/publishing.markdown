# Publishing Documents on your Web Site

To publish one of your documents from DocumentCloud on to your web site, you can either download a standalone copy of the viewer that contains all of your annotations right in it, or cut and paste a simple embed code for that document. The instructions that follow assume some basic familiarity with HTML, but we've tried to keep the embedding process as simple as possible.

For live examples, we're keeping a list of some of our [favorite embedded documents][], though it is by no means comprehensive.  If you've done some great reporting that isn't there, [let us know][] about it. 
 
## Caveats

First, a note about public documents. Right now, no one can see your "public" documents unless they're a registered user who is part of our beta. Soon, we'll be opening the archive to the general public, and "public" documents will be available to anyone who searches for them.

DocumentCloud is still actively in beta. That means a lot of things, but when it comes to embedding documents it means this: First, you are reliant on our servers. This means that if our servers go down your document goes down. You can host documents yourself, but you'll miss out on bug fixes, and will have to manually upgrade to newer versions of the viewer. Second, we can't make any promises. We test our work well, but we are actively working on this software and vulnerable to hosting glitches. Take a look at our [terms and conditions][] for a fuller disclaimer of liability.
 
## Step 1: Create a Template

If you want your readers to view a document, you'll need to embed it on your website. For that, you need a template, with your own logo, links, analytics, and advertising. We recommend that the layout be fluid-width, with just a header -- the viewer will take up the rest of the page.
 
Here are some live examples worth checking out: [NewsHour][], [Arizona Republic][], [Chicago Tribune][], [ProPublica][], but there are [plenty more][].

<img src="/images/help/newshour.jpg" class="full_line" />

If you'd prefer to fit the document into an existing layout, and not have the viewer be full-screen, this can be accomplished by using CSS to set the style of the document's containing element to "relative", and giving the containing element a width and height of your choosing. For an example of this style of embed, take a look at [this document from the Commercial Appeal][].
 
## Step 2: Check Your Metadata

Before you embed a document on your site, we encourage you to use the workspace to fill out a few bits of extra information about the document.
 
Metadata        | &nbsp;
----------------|--------------------
Title           | Does the title in DocumentCloud jibe with the title you're planning for the article?
Description     | Some visitors will come straight to the document rather than finding it through an article, so be sure the description field has enough information to put the document in context.
Source          | Currently, DocumentCloud's embeddable viewer doesn't include the information from the "source" field, but it does appear in search results, and should be accurate.
Related&nbsp;Article | It's important to supply the URL for the related article so that readers can find their way back to the original reporting.
 
Almost all of these fields can be edited as a batch: select as many documents as you're getting ready to publish and click on the "edit" menu. (Each document's title and description must be edited separately.)
 
## Step 3: Make Your Documents Public

To publish a document, you'll need to make it public, if it isn't already. Select the document (or documents) and then pick "Edit Access Level" from the menu "Edit" menu. Change the access level to "Public". For large documents, it will take a couple minutes to upload all of the image files with the new permissions.
 
*Note: once you change a document to "public" other users of DocumentCloud will be able to find it in searches of the repository. Don't make sensitive documents public in advance of publication.*
 
## Step 4: Copy and Paste the Embed Code onto the Page

![Embed Menu][]

When working with embedded documents, at first you can try out the embed code in your template while the document is still private, but the document viewer won't load if you log out of your account.

To get the embed code, select your document, open the "Publish" menu, and click "Embed Document Viewer". A dialog appears containing a bit of HTML, which will look something like this:

    <div id="document-viewer"></div>
    <script src="http://s3.documentcloud.org/viewer/loader.js"></script>
    <script>
      DV.load('http://www.documentcloud.org/documents/10-general-report.js', {
        container : '#document-viewer'
      });
    </script>

You'll notice, if you study it closely, that the URL for the document's JavaScript looks remarkably like the document's own URL: only the file extension is changed, from `html` to `js`.

The `DV.load` call has a couple of options. The only required one is `container`, which uses a selector to specify the element on the page into which you'd like to place the viewer. If you use a different element, feel free to remove the `div` from the top of the snippet.

The other option you can currently use is `zoom`, which will set the initial zoom level of the viewer. The allowed zoom levels are `500`, `700`, `800`, `900`, and `1000` pixels wide. `700` is the default.
 
## Step 5: Stay in Touch

[Let us know][] about your reporting. Even if it is "just a little local story" -- we're interested in all the reporting you do with DocumentCloud.

Still have questions about publishing documents? Don't hesitate to [contact us][].

[Embed Menu]: /images/help/embed_menu.png
[favorite embedded documents]: http://documentcloud.pbworks.com/Document-Dives
[terms and conditions]: /terms
[plenty more]: /featured
[NewsHour]: http://www.pbs.org/newshour/rundown/stevens-testimony.html
[Arizona Republic]: http://www.azdatapages.com/sb1070.html
[Chicago Tribune]: http://media.apps.chicagotribune.com/docs/obama-subpoena.html
[ProPublica]: http://www.propublica.org/documents/item/magnetars-responses-to-our-questions
[this document from the Commercial Appeal]: http://www.commercialappeal.com/data/documents/bass-pro-lease/
