# The DocumentCloud API

DocumentCloud's API provides resources to search, upload, edit, and organize documents as well as to work with projects. In addition, an oEmbed service provides easy integration of embedding documents, pages and notes.

Use of the DocumentCloud API indicates you have read and agree to our [API Guidelines and Terms of Service](/terms/api).

## Contents

* Document methods:
  * [Search](#search-documents)
  * [Upload](#upload-documents)
  * [Get](#get-document)
  * [Update](#update-document)
  * [Delete](#delete-document)
  * [Entities](#get-entities)
* Project methods:
  * [Create](#create-project)
  * [List projects](#get-projects)
  * [Update](#update-project)
  * [Delete](#delete-project)
* [oEmbed](#oembed):
  * [Documents](#oembed-documents)
  * [Pages](#oembed-pages)
  * [Notes](#oembed-notes)
* [API Wrappers and Utilities](#api-wrappers)

# Document Methods

<a name="search-documents"></a>
## GET /api/search.json

Search the catalog of public documents. This method can be used to scrape the public documents from your account for embedding purposes or to enable searches of your archive of uploaded documents directly from your own website. See our <a href="searching">search documentation</a> for help with search queries.

Parameter     | Description           |  Example
--------------|-----------------------|--------------
q             | the search query      | group:nytimes title:nuclear
page          | response page number  | 3 (defaults to 1)
per_page      | the number of documents to return per page | 100 (defaults to 10, max is 1,000)
sections      | include document sections in the results | true (not present by default)
annotations   | include document annotations in the results | true (not present by default)
data          | include key/value data in the results | true (not present by default)
mentions      | include highlighted mentions of the search phrase | 3 (not present by default, max is 10)
order         | the order by which documents are listed | title (default is "created\_at", other choices are: "score", "created\_at", "title", "page_count", "source")

### Example

    /api/search.json?q=obama&page=2

<div class="api_search_form">
  <p>
    Use the search form below to try queries and see what the resulting JSON looks like.
  </p>
  <div>
    <form id="search_form" action="about:blank" autocomplete="off">
      <div id="run_search" class="minibutton default">Search</div>
      <div class="text_input">
        <div class="background">
          <div class="inner">
            <input type="text" name="q" id="q" />
          </div>
        </div>
      </div>
      <label for="q">
        Search Query:
        <div>ex: "title:arrest"</div>
      </label>
    </form>
  </div>

  <pre id="search_results" style="display: none;"></pre>
</div>

### Tips

 * If you'd like to get back search results with more than 10 documents on a page, pass the `per_page` parameter. A maximum of 1,000 documents will be returned at a time.

<a name="upload-documents"></a>
## POST /api/upload.json

Our API for bulk uploads exposes the same method that we use internally, but wraps it in basic authentication over HTTPS. Documents will be uploaded into the authenticated account.

You can either upload a local file using a standard multi-part upload, or tell DocumentCloud to download the file from a public server by passing a URL.

Parameter     | Description           |  Example
--------------|-----------------------|--------------
file            | (required) either the contents of a local file, or the URL where the document can be found | --
title           | (required) the document's canonical title | 2008 Blagojevich Tax Return
source          | (optional) the source who produced the document | U.S. Attorney's Office
description     | (optional) a paragraph of detailed description | This prosecution exhibit is the 2008 joint tax return for Rod and Patti Blagojevich. It shows their total income for the year was $284,000.
language        | (optional) The language of the document.  Will be used to determine what OCR package to use for files that require OCR processing. Default is: "eng" | eng
related_article | (optional) the URL of the article associated with the document | http://example.com/news/blago/2010-5-3.html
published_url   | (optional) the URL of the page on which the document will be embedded | http://documents.example.com/blago-transcript.html
access          | (optional) one of "public", "private", "organization", defaults to "private" | public
project         | (optional) a numeric Project id, to upload the document into an existing project | 1012
data            | (optional) a hash of arbitrary key/value data pairs | {"data": {"status": "active"}} (json) <br /> data[status]=active (query string)
secure          | (optional) If you're dealing with a truly sensitive document, pass the "secure" parameter in order to prevent the document from being sent to OpenCalais for entity extraction. | true
force_ocr | (optional) specify that a document should be OCR'd even if it has text in it (default is "false") | true

### Tips

 * Please ensure that you send the request properly encoded as "multipart/form-data"
 * Review your uploaded files and add a source and description if you didn't.

### Example

Using Ruby's RestClient library you could do:

    RestClient.post('https://ME%40TEST.COM:SECRET@www.documentcloud.org/api/upload.json',
      :file   => File.new('/full/path/to/document/document.pdf','rb'),
      :title  => "2008 Blagojevich Tax Return",
      :source => "U.S. Attorney's Office",
      :access => 'private',
      :data   => {"date" => "2009-04-01", "exhibit" => "E1146"}
    )

<a name="get-document"></a>
## GET /api/documents/[id].json

Retrieve the canonical JSON representation of a particular document, as specified by the document id (usually something like: **1659580-economic-analysis-of-the-south-pole-traverse**).

### Example Response

    {"document":{
      "id":"1659580-economic-analysis-of-the-south-pole-traverse",
      "title":"Economic Analysis of the South Pole Traverse",
      "access":"public"
      "pages":38,
      "description":"The South Pole Traverse is a highway of compacted snow built to provide an overland supply route between McMurdo Station on the Antarctic coast and the Amundsen–Scott South Pole Station.  This report provides an account of the logistical costs associated with transport across the Traverse compared with air transport via LC-130 Hercules aircraft.",
      "source":"http://www.dtic.mil/cgi-bin/GetTRDoc?AD=ADA602402",
      "created_at":"Wed, 11 Feb 2015 18:30:58 +0000",
      "updated_at":"Sun, 08 Mar 2015 15:23:02 +0000",
      "canonical_url":"https://www.documentcloud.org/documents/1659580-economic-analysis-of-the-south-pole-traverse.html",
      "language":"eng",
      "file_hash":"c07f7b640c4df2132bacb8dbfac1dcb65f978418",
      "contributor":"Ted Han",
      "contributor_organization":"DocumentCloud",
      "display_language":"eng",
      "resources":{
        "pdf":"https://assets.documentcloud.org/documents/1659580/economic-analysis-of-the-south-pole-traverse.pdf",
        "text":"https://assets.documentcloud.org/documents/1659580/economic-analysis-of-the-south-pole-traverse.txt",
        "thumbnail":"https://assets.documentcloud.org/documents/1659580/pages/economic-analysis-of-the-south-pole-traverse-p1-thumbnail.gif",
        "search":"https://www.documentcloud.org/documents/1659580/search.json?q={query}",
        "print_annotations":"https://www.documentcloud.org/notes/print?docs[]=1659580",
        "translations_url":"https://www.documentcloud.org/translations/{realm}/{language}",
        "page":{
          "image":"https://assets.documentcloud.org/documents/1659580/pages/economic-analysis-of-the-south-pole-traverse-p{page}-{size}.gif",
          "text":"https://www.documentcloud.org/documents/1659580/pages/economic-analysis-of-the-south-pole-traverse-p{page}.txt"
          },
        "annotations_url":"https://www.documentcloud.org/documents/1659580/annotations"
      },
      "sections":[],
      "data":{},
      "annotations":[]
    }}

### Tips

 * **Security note:** For fidelity with the source document, the extracted text (available via the URLs provided in `document.resources.text` and the `document.resources.page.text` page iteration pattern) is not sanitized. **You should always escape document and page text before insertion into the DOM.**

<a name="update-document"></a>
## PUT /api/documents/[id].json

Update a document's **title**, **source**, **description**, **related article**, **access level**, or **data** with this method. Reference your document by its id (usually something like: **1659580-economic-analysis-of-the-south-pole-traverse**).

Parameter     | Description           |  Example
--------------|-----------------------|--------------
title | (optional) the document's canonical title | 2008 Blagojevich Tax Return
source | (optional) the source who produced the document | U.S. Attorney's Office
description | (optional) a paragraph of detailed description | This prosecution exhibit is the 2008 joint tax return for Rod and Patti Blagojevich. It shows their total income for the year was $284,000.
related_article | (optional) the URL of the article associated with the document | http://example.com/news/blago/2010-5-3.html
published_url | (optional) the URL of the page on which the document will be embedded | http://documents.example.com/blago-transcript.html
access | (optional) one of "public", "private", "organization" | "public"
data | (optional) a hash of arbitrary key/value data pairs | {"data": {"status": "active"}} (json) <br /> data[status]=active (query string)

The response value of this method will be the JSON representation of your document (as seen in the GET method above), with all updates applied.

### Tips

 * If your HTTP client is unable to create a PUT request, you can send it as a POST and add an extra parameter: `_method=put`

<a name="delete-document"></a>
## DELETE /api/documents/[id].json

Delete a document from DocumentCloud. You must be authenticated as the owner of the document for this method to work.

### Tips

 * If your HTTP client is unable to create a DELETE request, you can send it as a POST, and add an extra parameter: `_method=delete`

<a name="get-entities"></a>
## GET /api/documents/[id]/entities.json

Retrieve the JSON for all of the entities that a particular document contains, specified by the document id (usually something like: **1659580-economic-analysis-of-the-south-pole-traverse**). Entities are ordered by their relevance to the document as determined by OpenCalais.

### Example Response

    {
      "entities":{
        "person":[
          { "value":"Ramadan Aff", "relevance":0.72 },
          { "value":"Sarah Normand", "relevance":0.612 },
          ...
        ],
        "organization":[
          { "value":"Supreme Court", "relevance":0.619 },
          { "value":"Hamas", "relevance":0.581 },
          ...
        ]
        ...
      }
    }

# Project Methods

<a name="create-project"></a>
## POST /api/projects.json

Create a new project for the authenticated account, with a title, optional description, and optional document ids.

Parameter     | Description           |  Example
--------------|-----------------------|--------------
title | (required) the projects's title | Drywall Complaints
description | (optional) a paragraph of detailed description | A collection of documents from 2007-2009 relating to reports of tainted drywall in Florida.
document_ids | (optional) a list of documents that the project contains, by id | 28-rammussen, 207-petersen

### Tips

 * Note that you have to use the convention for passing an array of strings: `?document_ids[]=28-boumediene&document_ids[]=207-academy&document_ids[]=30-insider-trading`

<a name="get-projects"></a>
## GET /api/projects.json

Retrieve a list of project names and document ids. You must use basic authentication over HTTPS in order to make this request. The projects listed belong to the authenticated account.

### Example Response

    {"projects": [
      {
        "id": 5,
        "title": "Literate Programming",
        "document_ids":[
          "103-literate-programming-a-practioners-view",
          "104-reverse-literate-programming"
        ]
      },
      ...
    ]}

<a name="update-project"></a>
## PUT /api/projects/[id].json

Update an existing project for the current authenticated account. You can set the title, description or list of documents. See POST, above.

<a name="delete-project"></a>
## DELETE /api/projects/[id].json

Delete a project that belongs to the current authenticated account.

<a name="oembed"></a>
# oEmbed

## GET /api/oembed.json

Generate an embed code for a resource (a document or a note) using our [oEmbed](http://oembed.com/) service. Returns a rich JSON response.

### Response format

    {
      "type": "rich",
      "version": "1.0",
      "provider_name": "DocumentCloud",
      "provider_url": "https://www.documentcloud.org/",
      "cache_age": 300,
      "height": 750,
      "width": 600,
      "html": "<script>...</script>"
    }

<a name="oembed-documents"></a>
### Example document request

    /api/oembed.json?url=https%3A%2F%2Fwww.documentcloud.org%2Fdocuments%2Fdoc-name.html&responsive=true

### Parameters for documents

Parameter        | Description           |  Example
-----------------|-----------------------|--------------
url              | **(required)** URL-escaped document to embed     | https%3A%2F%2Fwww.documentcloud.org%2F documents%2Fdoc-name.html
maxheight        | (optional) The viewer's height (pixels)    | 750
maxwidth         | (optional) The viewer's width (pixels)     | 600
container        | (optional) Specify the DOM container in which to embed the viewer | #my-document-div
notes            | (optional) Enable the notes tab   | true (default)
text             | (optional) Enable the text tab   | true (default)
zoom             | (optional) Show the zoom slider    | true (default)
search           | (optional) Show the search box    | true (default)
sidebar          | (optional) Show the sidebar    | true (default)
pdf              | (optional) Include a link to the original PDF    | true (default)
responsive       | (optional) Make the viewer responsive    | false (default)
responsive_offset| (optional) Specify header height (pixels)    | 4
default_note     | (optional) Open the document to a specific note. An integer representing the note ID | 214279
default_page     | (optional) Open the document to a specific page   | 3

<a name="oembed-pages"></a>
### Example pages request

    /api/oembed.json?url=https%3A%2F%2Fwww.documentcloud.org%2Fdocuments%2Fdoc-name%2Fpages%2F5.html

### Parameters for pages

Parameter        | Description           |  Example
-----------------|-----------------------|--------------
url              | **(required)** URL-escaped document page to embed     | https%3A%2F%2Fwww.documentcloud.org%2F documents%2Fdoc-name%2Fpages%2F5.html

<a name="oembed-notes"></a>
### Example note request

    /api/oembed.json?url=https%3A%2F%2Fwww.documentcloud.org%2Fdocuments%2Fdoc-name%2Fannotations%2F220666.html

### Parameters for notes

Parameter        | Description           |  Example
-----------------|-----------------------|--------------
url              | **(required)** URL-escaped document to embed     | https%3A%2F%2Fwww.documentcloud.org%2F documents%2Fdoc-name%2Fannotations%2F220666.html
container        | (optional) Specify the DOM container in which to embed the viewer | #my-document-div

<a name="api-wrappers"></a>
# API Wrappers and Utilities

The open-source community has contributed several helpful libraries for interacting with DocumentCloud's API. See their documentation for examples and more information:

**Node.js**

* [node-documentcloud](https://github.com/rdmurphy/node-documentcloud): A Node.js wrapper around the DocumentCloud API.

**Python:**

* [python-documentcloud](http://python-documentcloud.readthedocs.org/en/latest/): A simple Python wrapper for the DocumentCloud API.
* [pneumatic](http://pneumatic.readthedocs.org/en/latest/): A bulk-upload library for DocumentCloud.

**Ruby:**

* [Documentcloud](https://rubygems.org/gems/documentcloud/): RubyGem for interacting with the DocumentCloud API.

# Questions?

Still have questions about the API? Don't hesitate to [contact us][].

[contact us]: javascript:dc.ui.Dialog.contact()

<script type="text/javascript">
  $(function() {
    $('#search_form').submit(function(e) {
      e.preventDefault();
      $.getJSON('/api/search', {q : $('#q').val()}, function(resp) {
        $('#search_results').show().text(JSON.stringify(resp, null, 2));
      });
    });
    $('#run_search').click(function() {
      $('#search_form').submit();
    });
    $('#help table td:nth-child(2n)').addClass('desc');
  });
</script>
