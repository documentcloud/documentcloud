Comments, questions and doubts on DocumentCloud translation from English to Spanish
Fernando Diaz, 301-204-7300, fediaz@vivelohoy.com, fdiazreporting@gmail.com

I've kept all manner of speech informal in this translation, opting against the deferential formal tone that can be used in Spanish. It would be rather simple to switch, but formal is a bit old school and not necessary in this environment. There is no "usted" in this translation. Also, conjugating verbs has been done in the informal tone to maintain consistency. I did keep all of the pleases.

I kept OCR and PDF as there is a lot of use in Spanish of English acronyms. I also kept the definition in parens as optical character recognition, so it jives with the acronym, but "reconocimiento óptico de carácteres" is clear as well.

Not sure on the "best" translation for embed. I was on the fence about keeping it "embed" except where it needed to be conjugated, which could be confusing as I'm not sure most folks would understand "embedding." The most widely used translation I found was "incrustar" which is what I used. This could also be understood as a common technical term like OCR. In any case, I kept consistent with incrustar, so if you'd like it changed, or the folks in Argentina suggest otherwise, it's easy to do.

Found lots of "arbitrary capitalization" and I kept it. So where multiple terms in a string are in Caps, I kept them that way in the translation.

The "Shift" key. I'm pretty sure most keyboards have this button, especially in Spanish language, but not sure what they would call it. Check the keyboards when you get to Argentina to see what they have. 

For Upload I chose "Subir" instead of "Cargar," but the term is interchangeable and I kept it consistent so if it needs changing, it's a snap.

Gender can be tricky, depending on what is in the %s and %d. May help to see this in a staging environment to see how best to translate. also "y" for "and" might not be right depending on other word, whther it phonetically begins with an "i" which would mean it needs to be "e"

For "links" I used enlaces because it's shorter, but it could be "links" or "vínculos"

For "reviewers" I used Revisor, which folks will tell you is not a word. They're right. I tried other ways. but the words that appeared most appropriate are "crítico" or "reseñador", which are too close to critic or reviewer from the standpoint of criticism.

Numbers can be tricky in %s and %d because they modify the verb. I tried best intuit what the result would be, but worth checking in staging.

Detected use of anotations and notes. They're the same thing, right? In all cases I translated "Note" to "Nota" and "Annotation" to "Anotación"

Email is Email, but in some cases I translated to correo electrónico. As in send us an email vs. Email (address)

In the "Contact us" form I would recommend adding a country code for US.

Was confused here about the extra characters in beginning of this section, but translated as though they were simple %s
explain_disable_account: '%1$s will not be able to log in to DocumentCloud. Public documents and annotations provided by %1$s will remain available. %2$sContact support%3$s to completely purge %1$s''s account.'

Quotes go outside of punctuation like periods and commas in Spanish, I modified in almost all cases. Will review to see if I missed any.

Another technical term, Signup, was translated as a phrase.
signup_sent_to:  Signup sent to %s
	- this term is tricky. request for account ?
  signup_sent_to:  Solicitud para crear una cuenta enviada a %s

Not sure about best way to translate key value, might consider keeping in english. in spanish is clave and valor, literally, not sure if they use them that way, or use them in english.

edit_document_pairs:
  - Edit key/value pairs describing this document.
  - Edit key/value pairs describing these documents.

These were confusing: 

for_example_data: 'Por ejemplo: &ldquo;birth: 1935-01-08&rdquo;, or &ldquo;status:
    released&rdquo;'
	- confusing. 

# Document embed_code  
  mentioning_query: mentioning &ldquo;%s&rdquo;
	- not sure how to translate this

document_public_on: This document will be public on %s
 if %s is an amount of TIME it would be preceded by "en", if it's a DATE, would be "el". 

374 - log in to DocumentCloud to understand context of this set_the: set the, designar el?

I used "filtrar" for "Sort".

Sometimes you have single quotes, not sure if they are enclosing the string, or if they are meant to appear as single quotes. 

  has_no_entities: '%s no dispone de entidades para revisar.'

For OVERVIEW, I used "Panorama" since it speaks to a specific view, not a summary of the document and for TIMELINE I used "cronología".

There has to be a more elegant way of saying DOCUMENT VIEWER. I chose Marco, which means "frame" as it had the most general application. Perhaps this could be a topic of conversation with the Argentines.

These were confusing, the first for my lack of context, the second because of the "container element"

 - viewer:
  <<: *common
does this need translating? común?

container_not_found: 'Document Viewer container element not found:'
  # Error message that is displayed when a document is incorrectly embedded

Another gender issue: If it's only for annotations, then it can all be female. I translated all as female, referring to annotations/notes.
next: Next
  next_note: Next Annotation
  previous: Previous
  previous_note: Previous Annotation
  # These strings are displayed as navigation on annotations
  # They are hidden and shown as appropriate. 


Annotation vs Note. In the code, it's not, but in the text for folks it's both ways, are these two different types of text or two ways of saying the same thing?