# Directrices y Condiciones del Servicio de API

El API de DocumentCloud permite a los usuarios buscar, cargar, editar y organizar documentos. No se requiere ninguna clave de API, por lo cual realizar búsquedas directamente desde JavaScript es válido. Por favor sea amable, y no sobrecargue nuestros servidores. Restricciones sobre el uso de la API de DocumentCloud no aplican a las organizaciones aportadoras que trabajan con documentos cargados por sus propios usuarios.

 * Bajo ninguna circunstancia se permitirá la reproducción de DocumentCloud.org en su totalidad o construir una aplicación que simplemente muestre el conjunto completo de documentos. Tiene prohibido crear una aplicación que muestre el conjunto de documentos de una organización aportadora.
 * Si su proyecto permite a los usuarios interactuar con los datos de DocumentCloud, está obligado a  citar DocumentCloud como la fuente de sus datos. Si su proyecto permite a los usuarios ver o explorar documentos específicos, debe citar DocumentCloud, así como a  las organizaciones aportadoras pertinentes, identificadas en el API.
 * No se permite utilizar la API comercialmente,  lo que significa que no se permite cobrar dinero a la gente para mirar los datos, o vender publicidad con dicha información.
 * Usted entiende y acepta que los datos proporcionados por nuestro API pueden contener errores y omisiones.

_Nos reservamos el derecho de modificar estas directrices. Si usted infringe el espíritu de estas condiciones, sobre todo si utiliza la API para acceder e imprimir de forma sistemática los documentos que usted o su sala de redacción no contribuyó, anticipe ser bloqueado sin previo aviso._

## GET /api/search.json

Busque en el catálogo de documentos públicos. Este método se puede utilizar para extraer los documentos públicos de su cuenta con fines incrustarlos, o para permitir búsquedas de su archivo de documentos cargados directamente desde tu propio sitio web. Consulte  <a href="searching">nuestra información</a> de búsqueda para más ayuda con las consultas de búsqueda.

Parámetro     | Descripción           |  Ejemplo
--------------|-----------------------|--------------
q 	          |  la consulta de búsqueda			|          group:nytimes title:nuclear
page	      |  respuesta número de página			|         3 (defaults to 1)
per_page      |  el número de documentos a regresar por página 	      |      100 (defaults to 10, max  is 1000)
sections      |  incluyen secciones del documento en los resultados   |  true (not present by default)
annotations   |  incluyen notas de documentos en los resultados       |     true (not present by default)
data	      |  incluyen datos clave/de valor en los resultados	  |       true (not present by default)
mentions      |  incluyen las menciones destacadas de la frase de búsqueda    |      3 (not present by default, max is 10)

 
### Ejemplo

    /api/search.json?q=obama&page=2
<div class="api_search_form">
  <p>
    Utilice el campo de búsqueda de abajo para intentar consultas y ver como es el JSON resultante.
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
        Consulta de búsqueda
        <div>ej.: "person:geithner"</div>
      </label>
    </form>
  </div>

  <pre id="search_results" style="display: none;"></pre>
</div>

 
### Consejos

 * Si desea obtener resultados de búsqueda con más de diez documentos en una página, pase el parámetro per_page. Un máximo de 1000 documentos se devolverán a la vez.

## POST /api/upload.json


Nuestra API para cargas en conjunto expone el mismo método que se utiliza internamente, pero lo envuelve en la autenticación básica a través de HTTPS. Los documentos se cargan en la cuenta autenticada.

Puede cargar un archivo local utilizando una carga estándar de varias partes, u ordenando a DocumentCloud que descargue el archivo de un servidor público por medio de un URL.

Parámetro 	|	Descripción 					|	Ejemplo
------------|-----------------------------------|------------
file  	    | (requerido) ya sea el contenido de un archivo local o la  dirección URL donde el documento se puede encontrar | --
title 		| (requerido) el titulo canónico del documento 		| Declaración de impuestos de Blagojevich 2008
source		| (opcional) la fuente que produjo el documento 	|	U.S.  Attorney’s Office
description	| (opcional) un párrafo de descripción detallada impuestos 	|  Esta muestra de la acusación es la declaración conjunta de del 2008 de Rod y Patti Blagojevich.
language        | (optional) El lenguaje del documento. Se utilizará para determinar qué paquete de OCR que se utilizará para los archivos que requieren procesamiento de OCR. Tome por defecto "eng" | spa
related_article | (opcional) la dirección URL del artículo asociado     | http://example.com/news/blago/2010-5-3.html
published_url   |   (opcional) la dirección URL de la página en la que se integrará el documento | http://documents.example.com/blago-transcript.html
access		    |(opcional), una de "publico", "privado", "organización",público predeterminado como  "privado" |
project		    | (opcional) una identificación de proyectos numérica, para cargar el documento en un proyecto existente.   |       1012
data 		    | (opcional) una mezcla  de pares clave / valor de datos {"data": {"status": "active"}} (json) arbitrarios | data[status]=active (query string)
secure	        |   (opcional) Si está trabajando con un documento  realmente sensible, pase el parámetro "seguro" con el fin de evitar que el documento sea enviado a OpenCalais para extracción de entidades. | verdadero 

### Consejos

 * Por favor asegúrese de envíar la solicitud adecuadamente codificada como "multipart/form-data"
 * Revise sus archivos cargados y agregue  fuente y descripción si no lo ha hecho.

### Ejemplo

Usando biblioteca RestClient de Ruby podría hacerlo siguiente:


    RestClient.post('https://ME%40TEST.COM:SECRET@www.documentcloud.org/api/upload.json',
      :file   => File.new('/full/path/to/document/document.pdf','rb'),
      :title  => "2008 Blagojevich Tax Return",
      :source => "U.S. Attorney's Office",
      :access => 'private',
      :data   => {"date" => "2009-04-01", "exhibit" => "E1146"}
    )

## GET /api/documents/[id].json

Recupere la representación canónica JSON de un documento en particular, según especificado por el identificador del documento (normalmente algo como: **218-madoff-sec-report**).

## Ejemplo de respuesta

    {"document":{
      "id":"207-american-academy-v-napolitano",
      "title":"American Academy v. Napolitano",
      "pages":52,
      "language":"eng",
      "file_hash":"1c877b02d23dd1f49b55b9854e93a31c2df7e99d",
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

Actualice el **título**, **fuente**, **descripción**, **artículo relacionado**, **nivel de acceso**, o los datos de un documento, con este método. Refiérase a su documento por su ID (normalmente algo como: **218-madoff-sec-report**).

Parámetro 	|	Descripción 					|	Ejemplo
------------|-----------------------------------|------------
file  	    | (requerido) ya sea el contenido de un archivo local o la  dirección URL donde el documento se puede encontrar | --
title 		| (requerido) el titulo canónico del documento 		| Declaración de impuestos de Blagojevich 2008
source		| (opcional) la fuente que produjo el documento 	|	U.S.  Attorney’s Office
description	| (opcional) un párrafo de descripción detallada impuestos 	|  Esta muestra de la acusación es la declaración conjunta de del 2008 de Rod y Patti Blagojevich.
related_article | (opcional) la dirección URL del artículo asociado     | http://example.com/news/blago/2010-5-3.html
published_url   |   (opcional) la dirección URL de la página en la que se integrará el documento | http://documents.example.com/blago-transcript.html
access		    |(opcional), una de "publico", "privado", "organización",público predeterminado como  "privado" |
project		    | (opcional) una identificación de proyectos numérica, para cargar el documento en un proyecto existente.   |       1012
data 		    | (opcional) una mezcla  de pares clave / valor de datos {"data": {"status": "active"}} (json) arbitrarios | data[status]=active (query string)
secure	        |   (opcional) Si está trabajando con un documento  realmente sensible, pase el parámetro "seguro" con el fin de evitar que el documento sea enviado a OpenCalais para extracción de entidades. | verdadero 



El valor en la respuesta de este método será la representación JSON de su documento (como se ve en el método GET arriba), con todos las actualizaciones aplicadas.

## Consejos

 * Si su cliente HTTP no puede crear una solicitud PUT, puede enviarlo como POST, y añadir un parámetro adicional: _method=put
 

## DELETE/api/documents /[id].Json

Elimine un documento de DocumentCloud. Debe ser autentificado como el propietario del documento para que este método funcione.
Consejos

 * Si su cliente HTTP no puede crear una petición DELETE, puede enviarlo como POST, y añadir un parámetro adicional: _method=delete
 
## GET/api/documents/[id]/entities.json

Recupere el JSON de todas las entidades que un determinado documento contiene, especificado por el ID del documento (normalmente algo como: **218-madoff-sec-report**). Las entidades son ordenadas por su relevancia al  el documento según es determinado por OpenCalais.

### Ejemplo de respuesta



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

Cree un nuevo proyecto para la cuenta autenticada, con un título, una descripción opcional y los identificadores (IDs) de documentos opcionales.

Parámetro 	|	Descripción 					|	Ejemplo
------------|-----------------------------------|------------
title 		| (obligatorio) El título del proyecto 	    	|	Drywall Complaints
description	| (opcional) un párrafo de descripción detallada  	| Una colección de documentos de 2007-2009 relacionados con los informes de paneles de yeso contaminados en Florida.
document_ids | 	(opcional) una lista de los documentos que el proyecto contiene, por id | 28-rammussen, 207-petersen
 
## Consejos
 * Tenga en cuenta que tiene que utilizar la convención para pasar una matriz de cadenas: `?document_ids[]=28-boumediene&document_ids[]=207-academy&document_ids[]=30-insider-trading`

## GET/api/projects.json

Recupere una lista de nombres de proyectos y IDs de documentos. Debe utilizar la autenticación básica a través de HTTPS para hacer esta solicitud. Los proyectos presentados a continuación pertenecen a la cuenta autenticada.

### Ejemplo de respuesta

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


## PUT/api/projects/[id].json

Actualice un proyecto existente para la cuenta actual autenticada. Puede definir el título, la descripción o la lista de documentos. Véase POST, arriba.

## DELETE/api/projects /[id].json

Borre un proyecto que pertenezca a la cuenta actual autenticada.

¿Aún tiene preguntas acerca de cómo colaborar? No dude en [comunicarse con nosotros](javascript:dc.ui.Dialog.contact(\)).
