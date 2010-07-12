# Searching for Documents

This guide lists the different types of searches you can perform with DocumentCloud. You can click any of the linked examples to run the search and try it out.

By default, a search looks for all of the words you enter within the full text of the document itself. For example: [John Yoo detainee][]. You can, however, ask DocumentCloud to search the contents of specific other fields.

When entering a fielded search, if the phrase you're searching for contains spaces, use quotation marks to surround the phrase. If there are no spaces, quotes aren't necessary.
   
Term                        | Description 
----------------------------|---------------------
account                     | Specify an email address to see documents uploaded by a single user. For example: <span class="ajax-only">[account: scott.klein@propublica.org][]</span><span class="static-only">`account: scott.klein@propublica.org`</span>.
group                       | If you know the short name of an organization, you can search for documents uploaded by anyone in that newsroom. For example: <span class="ajax-only">[group: chicago-tribune][]</span><span class="static-only">`group: chicago-tribune`</span>.
project                     | Restrict your search to just the documents in one of your projects, by entering the title. This is the same as clicking on the project in the "Projects" tab.
title                       |	Will search for documents by title, as provided by the person who uploaded it. For example: <span class="ajax-only">[title: deepwater][]</span><span class="static-only">`title: deepwater`</span>
source                      | When you upload a document, you have the opportunity to identify the source. This provides a way to search that field. For example: <span class="ajax-only">[source: supreme][]</span><span class="static-only">`source: supreme`</span> will identify documents attributed to "U.S. Supreme Court" as well as "New York State Supreme Court."
 
# Searching with Entities
 
For each document we store a list of entities identified by [OpenCalais][]. These are the same entities that appear in the "Entities" tab on the left. After searching for an entity, you can click on "show pages" to display links to the specific pages in each document that mention the person, place or thing you're searching for.

Term                        | Description 
----------------------------|-------------------------
person                      | The name of a human being. If you're looking for documents that reference a person with the last name of "Lee", but keep getting swamped with unrelated words, try narrowing your search to <span class="ajax-only">[person: Lee][]</span><span class="static-only">`person: Lee`</span>.
organization                | Organizations include businesses, government agencies, and other types of institutions. For example: <span class="ajax-only">[organization: "Department of Defense"][]</span><span class="static-only">`organization: "Department of Defense"`</span>.
term                        | Searches for terms might include <span class="ajax-only">[term: "nuclear energy"][]</span><span class="static-only">`term: "nuclear energy"`</span> or <span class="ajax-only">[term: "gross domestic product"][]</span><span class="static-only">`term: "gross domestic product"`</span> The results will be comparable to searching for the terms directly.
place                       | Addresses, names of buildings and landmarks, regions, or geographical landmarks. For example: <span class="ajax-only">[place: "World Trade Center"][]</span><span class="static-only">`place: "World Trade Center"`</span> or <span class="ajax-only">[place: "Gulf of Mexico"][]</span><span class="static-only">`place: "Gulf of Mexico"`</span>.
city                        | For example: <span class="ajax-only">[city: "New Orleans"][]</span><span class="static-only">`city: "New Orleans"`</span>
state                       | (Includes provinces, in countries that have provinces instead of states.) For example: <span class="ajax-only">[state: Arizona][]</span><span class="static-only">`state: Arizona`</span>
country                     | For example: <span class="ajax-only">[country: Iran][]</span><span class="static-only">`country: Iran`</span>

Still have questions about how to search? Don't hesitate to [contact us][].

[OpenCalais]: http://www.opencalais.com/
