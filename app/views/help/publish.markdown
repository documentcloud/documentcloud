# Publishing Documents on your Web Site

To publish one of your documents from DocumentCloud on to your web site, you can either download a standalone copy of the viewer that contains all of your annotations right in it, or cut and paste a simple embed code for that document. The instructions that follow assume some basic familiarity with HTML, but we've tried to keep the embedding process as simple as possible.

For live examples, we're keeping a list of some of our [favorite embedded documents][], though it is by no means comprehensive.  If you've done some great reporting that isn't there, [let us know][] about it. 
 
# Caveats

First, a note about public documents. Right now, no one can see your "public" documents unless they're a registered user who is part of our beta. Soon, we'll be opening the archive to the general public, and "public" documents will be available to anyone who searches for them.

DocumentCloud is still actively in beta. That means a lot of things, but when it comes to embedding documents it means this: First, you are reliant on our servers. This means that if our servers go down your document goes down. You can host documents yourself, but you'll miss out on bug fixes, and will have to manually upgrade to newer versions of the viewer. Second, we can't make any promises. We test our work well, but we are actively working on this software and vulnerable to hosting glitches. Take a look at our [terms and conditions][] for a fuller disclaimer of liability.
 
# Step 1: Create a Template

If you want your readers to view a document, you'll need to embed it on your website. For that, you need a template, with your own logo, links, analytics, and advertising. We recommend that the layout be fluid-width, with just a header -- the viewer will take up the rest of the page.
 
Here are some live examples worth checking out: [NewsHour][], [Arizona Republic][], [Chicago Tribune][], [ProPublica][], but there are [plenty more][].

![NewsHour Example][]

If you'd prefer to fit the document into an existing layout, and not have the viewer be full-screen, this can be accomplished by using CSS to set the style of the document's containing element to "relative", and giving the containing element a width and height of your choosing. For an example of this style of embed, take a look at [this document from the Commercial Appeal][].
 
# Step 2: Check Your Meta Data

Before you embed a document on your site, be sure it has a clear title, description and source. If you want readers to be able to find the accompanying article, be sure to add a link to your related reporting. You can add all these things from either the workspace or from the document viewer.
 
Metadata        | &nbsp;
----------------|--------------------
Title           | Does the title in DocumentCloud match the title you're planning for the page?
Description     | Some users will come straight to the document rather than finding it through an article, so be sure the description field has enough information to put the document in context.
Source          | Currently, DocumentCloud's embeddable viewer doesn't include the information from the "source" field, but this should still be accurate.
Related Article | Definitely supply the URL for the related news story so that readers can find their way back to the reporting on the document.
 
Almost all of these fields can be edited as a batch: select as many documents as you're getting ready to publish and click on the "edit" menu. Each document's title and description must be edited separately.
 
# Step 3: Make Your Documents Public

To publish a document, you'll need to first select the document (or as many documents as you're ready to publish) and then select "Edit Access Level" from the menu "Edit" menu. Change the access level to "Public" and then open each document.
 
Note: once you change a document to "public" other users of DocumentCloud will be able to find it in searches of the repository. Don't make sensitive documents public in advance of publication! 
 
# Step 4: Download the HTML

Select a document and then look at the Publish menu for options. Note: at this stage, you can only embed documents you own.
 
**IMAGE**
 
# Step 5: Paste the HTML in Your Template

You won't be able to access your public documents directly on our site unless you are logged in, but you will be able to post a viewer in your template. Here's some sample viewer HTML. You'll notice, if you study it closely, that the URL for the document javascript looks remarkably like the document's own URL: only the file extension is changed, from html to js.
 
# Step 6: Stay in Touch

Let us know about your reporting. Even if it is "just a little local story" -- we're interested in all the reporting you do with DocumentCloud, not just work with national significance.

[favorite embedded documents]: http://documentcloud.pbworks.com/Document-Dives
[let us know]: javascript:dc.app.workspace.help.openContactDialog()
[terms and conditions]: /terms
[plenty more]: http://documentcloud.pbworks.com/Document-Dives
[NewsHour]: http://www.pbs.org/newshour/rundown/stevens-testimony.html
[Arizona Republic]: http://www.azdatapages.com/sb1070.html
[Chicago Tribune]: http://media.apps.chicagotribune.com/docs/obama-subpoena.html
[ProPublica]: http://www.propublica.org/documents/item/magnetars-responses-to-our-questions
[NewsHour Example]: /images/help/newshour.jpg
[this document from the Commercial Appeal]: http://www.commercialappeal.com/data/documents/bass-pro-lease/