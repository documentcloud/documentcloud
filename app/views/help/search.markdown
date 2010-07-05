Currently searches of the repository are only available to registered beta users. If you'd like to be one, [contact us](http://documentcloud.org/contact).
 
# API Searches

If you're currently logged-in, you can review our search API at [www.documentcloud.org/api](http://www.documentcloud.org/api)
 
# Workspace Searches

By default, a DocumentCloud search looks for your search terms in the document itself. You can, however, ask DocumentCloud to search other fields:
   
Term                        | Description 
----------------------------|---------------------
account (was "documents")   | Specify an email address to see documents uploaded by a single user. For example: account:amanda@documentcloud.org
description                 | Search for documents that contain the search term in the document description. 
group (was "organization")  | If you know the short name of an organization, you can search for documents uploaded by that newsroom or organization. For example: group:propublica or group:dcloud.
project                     | Search within a single project
source                      | Will search for documents that contain the search terms in the "source" field. For example: source:defense will identify documents attributed to "Department of Defense" or "Defense Department" or the "Civil Defense Museum."
title                       |	Will search for documents by titles, as provided by the user who uploaded it. By default, DocumentCloud search does not look in document titles for search terms. A search for title:conyers will find a document called "This is not about John Conyers" even if his name appears no where in that document.
 
You can also search for specific entities identified by OpenCalais.

Term                        | Description 
----------------------------|-------------------------
person                      | The name of a human being. If you're looking for documents that reference a person named "June" but keep getting date references, try narrowing your search to person:June
place                       | Almost any place. This is our broadest geographical search and will search OpenCalais entites for any geographic reference, including states and countries which you can also specify. Eg. place:"Rockefeller Plaza" or place:"New York"
city, state and country	    | In addition to the broader "place" search, you can also search for cities, US states and countries explicitly. Eg. city:"New Orleans" or country:China
term                        | Terms might include "investment banks" or "law enforcement." The results will be comparable to searching for the terms directly. 
organization                | Organizations include businesses and government agencies. eg. organization: "US Army"
