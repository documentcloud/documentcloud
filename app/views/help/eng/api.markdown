# API Guidelines and Terms of Service

DocumentCloud's API allows users to search, upload, edit, and organize documents. No API key is required, so performing searches directly from JavaScript is fair game. Please be considerate, and don't hammer our servers. _Restrictions on the use of the DocumentCloud API do not apply to participating organizations working with documents uploaded by their own users._

 * You may not recreate DocumentCloud.org in its entirety or build an application that simply displays the complete set of documents. You may not build an application that displays the document set of a contributing organization.

 * If your project allows users to interact with data from DocumentCloud, you must cite DocumentCloud as the source of your data. If your project allows users to view or browse specific documents, you must cite DocumentCloud and the relevant contributing organizations, as identified in the API.

 * You may not use the API commercially, by which we mean you may not charge people money to look at the data or sell advertising specifically against it.

 * You understand and acknowledge that any data provided by our API may contain errors and omissions.

_We reserve the right to revise these guidelines. If you violate the spirit of these terms, especially if you use the API to systematically access and reprint documents that you or your newsroom didn't contribute, expect to be blocked without advance warning._

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
        <div>ex: "person:geithner"</div>
      </label>
    </form>
  </div>

  <pre id="search_results" style="display: none;"></pre>
</div>

### Tips

 * If you'd like to get back search results with more than 10 documents on a page, pass the `per_page` parameter. A maximum of 1,000 documents will be returned at a time.

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
project         | (optional) a numeric Project id, to upload the document into an existing project. | 1012
data            | (optional) a hash of arbitrary key/value data pairs | {"data": {"status": "active"}} (json) <br /> data[status]=active (query string)
secure          | (optional) If you're dealing with a truly sensitive document, pass the "secure" parameter in order to prevent the document from being sent to OpenCalais for entity extraction. | true

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

## GET /api/documents/[id].json

Retrieve the canonical JSON representation of a particular document, as specified by the document id (usually something like: **218-madoff-sec-report**).

### Example Response

    {"document":{
      "id":"207-american-academy-v-napolitano",
      "title":"American Academy v. Napolitano",
      "pages":52,
      "language":"eng",
      "display_language":"eng",
      "description":"Appeal from the judgment of the United States District Court, granting summary judgment...",
      "created_at":"Fri Dec 10 03:43:23 +0000 2010",
      "updated_at":"Fri Jan 14 14:49:11 +0000 2011",
      "resources":{
        "pdf":"http://s3.documentcloud.org/documents/207/american-academy-v-napolitano.pdf",
        "text":"http://s3.documentcloud.org/documents/207/american-academy-v-napolitano.txt",
        "thumbnail":"http://s3.documentcloud.org/documents/207/pages/american-academy-v-napolitano-p1-thumbnail.gif",
        "search":"http://s3.documentcloud.org/207/search.json?q={query}",
        "page":{
          "text":"http://s3.documentcloud.org/documents/207/pages/american-academy-v-napolitano-p{page}.txt",
          "image":"http://s3.documentcloud.org/asset_store/documents/207/pages/american-academy-v-napolitano-p{page}-{size}.gif"
        },
        "related_article":"http://example.com/article.html"
      },
      "sections":[],
      "annotations":[]
    }}

## PUT /api/documents/[id].json

Update a document's **title**, **source**, **description**, **related article**, **access level**, or **data** with this method. Reference your document by its id (usually something like: **218-madoff-sec-report**).

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

## DELETE /api/documents/[id].json

Delete a document from DocumentCloud. You must be authenticated as the owner of the document for this method to work.

### Tips

 * If your HTTP client is unable to create a DELETE request, you can send it as a POST, and add an extra parameter: `_method=delete`

## GET /api/documents/[id]/entities.json

Retrieve the JSON for all of the entities that a particular document contains, specified by the document id (usually something like: **218-madoff-sec-report**). Entities are ordered by their relevance to the document as determined by OpenCalais.

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

## POST /api/projects.json

Create a new project for the authenticated account, with a title, optional description, and optional document ids.

Parameter     | Description           |  Example
--------------|-----------------------|--------------
title | (required) the projects's title | Drywall Complaints
description | (optional) a paragraph of detailed description | A collection of documents from 2007-2009 relating to reports of tainted drywall in Florida.
document_ids | (optional) a list of documents that the project contains, by id | 28-rammussen, 207-petersen

### Tips

 * Note that you have to use the convention for passing an array of strings: `?document_ids[]=28-boumediene&document_ids[]=207-academy&document_ids[]=30-insider-trading`

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

## PUT /api/projects/[id].json

Update an existing project for the current authenticated account. You can set the title, description or list of documents. See POST, above.

## DELETE /api/projects/[id].json

Delete a project that belongs to the current authenticated account.

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
