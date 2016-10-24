# El API de DocumentCloud

El API proporciona recursos para buscar, cargar, editar y organizar documentos, así como para trabajar con proyectos. Además, un servicio oEmbed proporciona una fácil integración de incrustación de documentos, páginas y notas.

Use of the DocumentCloud API indicates you have read and agree to our [Directrices y Condiciones del Servicio de API](/terms/api).

## Contenido

* General:
  * [Directrices y Condiciones del Servicio de API](/terms/api)
* Métodos de Documento:
  * [Busque](#search-documents)
  * [Cargar](#upload-documents)
  * [Obtener](#get-document)
  * [Actualizar](#update-document)
  * [Borre](#delete-document)
  * [Entitades](#get-entities)
* Métodos de Proyecto:
  * [Crear](#create-project)
  * [Listar de proyectos](#get-projects)
  * [Actualizar](#update-project)
  * [Borre](#delete-project)
* [oEmbed](#oembed):
  * [Documentos](#oembed-documents)
  * [Páginas](#oembed-pages)
  * [Notas](#oembed-notes)
* [Envolturas de la API y Utilidades](#api-wrappers)

# Métodos de Documento

<a name="search-documents"></a>
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
        <div>ej.: "title:arrest"</div>
      </label>
    </form>
  </div>

  <pre id="search_results" style="display: none;"></pre>
</div>


### Consejos

 * Si desea obtener resultados de búsqueda con más de diez documentos en una página, pase el parámetro per_page. Un máximo de 1000 documentos se devolverán a la vez.

<a name="upload-documents"></a>
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
secure	        |   (opcional) Si está trabajando con un documento  realmente sensible, pase el parámetro "seguro" con el fin de evitar que el documento sea enviado a OpenCalais para extracción de entidades. | true
force_ocr | (opcional) especifica que un documento debe OCR'd incluso si tiene texto en él (default is "false") | true


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

<a name="get-document"></a>
## GET /api/documents/[id].json

Recupere la representación canónica JSON de un documento en particular, según especificado por el identificador del documento (normalmente algo como: **1659580-economic-analysis-of-the-south-pole-traverse**).

## Ejemplo de respuesta

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

### Consejos

 * **Nota de seguridad:** Por fidelidad con el documento de origen, el texto extraído (disponible a través de las direcciones URL proporcionadas en `document.resources.text` y `document.resources.page.text` modelo paginación iteración) no es verificada. Siempre debe escape de documentos y páginas de texto antes de la inserción en el DOM.

<a name="update-document"></a>
## PUT /api/documents/[id].json

Actualice el **título**, **fuente**, **descripción**, **artículo relacionado**, **nivel de acceso**, o los datos de un documento, con este método. Refiérase a su documento por su ID (normalmente algo como: **1659580-economic-analysis-of-the-south-pole-traverse**).

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
secure	        |   (opcional) Si está trabajando con un documento  realmente sensible, pase el parámetro "seguro" con el fin de evitar que el documento sea enviado a OpenCalais para extracción de entidades. | true

El valor en la respuesta de este método será la representación JSON de su documento (como se ve en el método GET arriba), con todos las actualizaciones aplicadas.

## Consejos

 * Si su cliente HTTP no puede crear una solicitud PUT, puede enviarlo como POST, y añadir un parámetro adicional: `_method=put`

<a name="delete-document"></a>
## DELETE/api/documents /[id].Json

Elimine un documento de DocumentCloud. Debe ser autentificado como el propietario del documento para que este método funcione.
Consejos

 * Si su cliente HTTP no puede crear una petición DELETE, puede enviarlo como POST, y añadir un parámetro adicional: `_method=delete`

<a name="get-entities"></a>
## GET/api/documents/[id]/entities.json

Recupere el JSON de todas las entidades que un determinado documento contiene, especificado por el ID del documento (normalmente algo como: **1659580-economic-analysis-of-the-south-pole-traverse**). Las entidades son ordenadas por su relevancia al  el documento según es determinado por OpenCalais.

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

# Métodos de Proyecto

<a name="create-project"></a>
## POST /api/projects.json

Cree un nuevo proyecto para la cuenta autenticada, con un título, una descripción opcional y los identificadores (IDs) de documentos opcionales.

Parámetro 	|	Descripción 					|	Ejemplo
------------|-----------------------------------|------------
title 		| (obligatorio) El título del proyecto 	    	|	Drywall Complaints
description	| (opcional) un párrafo de descripción detallada  	| Una colección de documentos de 2007-2009 relacionados con los informes de paneles de yeso contaminados en Florida.
document_ids | 	(opcional) una lista de los documentos que el proyecto contiene, por id | 28-rammussen, 207-petersen

## Consejos
 * Tenga en cuenta que tiene que utilizar la convención para pasar una matriz de cadenas: `?document_ids[]=28-boumediene&document_ids[]=207-academy&document_ids[]=30-insider-trading`

<a name="get-projects"></a>
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

<a name="update-project"></a>
## PUT/api/projects/[id].json

Actualice un proyecto existente para la cuenta actual autenticada. Puede definir el título, la descripción o la lista de documentos. Véase POST, arriba.

<a name="delete-project"></a>
## DELETE/api/projects /[id].json

Borre un proyecto que pertenezca a la cuenta actual autenticada.

<a name="oembed"></a>
# oEmbed

## GET /api/oembed.json

Generar un código de inserción para un recurso (un documento o una nota) utilizando nuestro servicio [oEmbed](http://oembed.com/). Devuelve una rica respuesta JSON.

### Formato de respuesta

    {
      "type": "rich",
      "version": "1.0",
      "provider_name": "DocumentCloud",
      "provider_url": "https://www.documentcloud.org/",
      "cache_age": 300,
      "resource_url": "https://www.documentcloud.org/documents/doc-name.html",
      "height": 750,
      "width": 600,
      "display_language": "en",
      "html": "<script>...</script>"
    }

<a name="oembed-documents"></a>
### Ejemplo petición documento

    /api/oembed.json?url=https%3A%2F%2Fwww.documentcloud.org%2Fdocuments%2Fdoc-name.html&responsive=true

### Parámetros para documentos

Parámetro   | Descripción           | Ejemplo
-----------------|-----------------------|--------------
url              | **(requerido)** De escape de URL documento para incrustar | https%3A%2F%2Fwww.documentcloud.org %2Fdocuments%2Fdoc-name.html
maxheight        | (opcional) La altura del espectador (pixels)    | 750
maxwidth         | (opcional) La ancho del espectador (pixels)     | 600
container        | (opcional) Especifique el contenedor DOM en el que se incorporará al espectador | #my-document-div
notes            | (opcional) Activar la pestaña de notas   | true (default)
text             | (opcional) Activar la pestaña de texto   | true (default)
zoom             | (opcional) Mostrar el deslizador de zoom    | true (default)
search           | (opcional) Mostrar el caja de búsqueda    | true (default)
sidebar          | (opcional) Mostrar la barra lateral    | true (default)
pdf              | (opcional) Para incluir un enlace al PDF original    | true (default)
responsive       | (opcional) Hacer que el espectador adaptable    | false (default)
responsive_offset| (opcional) Especifique la altura del cabezal (pixels)    | 4
default_note     | (opcional) Abra el documento en una nota específica. Un entero que representa el ID de nota | 214279
default_page     | (opcional) Abra el documento a una página específica   | 3

<a name="oembed-pages"></a>
### Ejemplo petición página

    /api/oembed.json?url=https%3A%2F%2Fwww.documentcloud.org%2Fdocuments%2Fdoc-name%2Fpages%2F5.html

### Parameters for pages

Parameter        | Description           |  Example
-----------------|-----------------------|--------------
url              | **(required)** De escape de URL documento página para incrustar     | https%3A%2F%2Fwww.documentcloud.org%2F documents%2Fdoc-name%2Fpages%2F5.html

<a name="oembed-notes"></a>
### Ejemplo petición nota

    /api/oembed.json?url=https%3A%2F%2Fwww.documentcloud.org%2Fdocuments%2Fdoc-name%2Fannotations%2F220666.html

### Parámetros para notas

Parámetro   | Descripción           | Ejemplo
-----------------|-----------------------|--------------
url              | **(required)** De escape de URL documento para incrustar     | https%3A%2F%2Fwww.documentcloud.org%2F documents%2Fdoc-name%2Fannotations%2F220666.html
container        | (optional) Especifique el contenedor DOM en el que se incorporará al espectador | #my-document-div

<a name="api-wrappers"></a>
# Envolturas de la API y Utilidades

La comunidad de código abierto ha contribuido varias aplicaciones votos para interactuar con el API del DocumentCloud. Ver la documentación de ejemplos y más información:

**Node**

* [node-documentcloud](https://github.com/rdmurphy/node-documentcloud): Una envoltura alrededor de la API Node.js DocumentCloud.

**Python:**

* [python-documentcloud](http://python-documentcloud.readthedocs.org/en/latest/): Un envoltorio de Python simple para la API DocumentCloud.
* [pneumatic](http://pneumatic.readthedocs.org/en/latest/): Una biblioteca de carga para cargas masivas de DocumentCloud.

**Ruby:**

* [Documentcloud](https://rubygems.org/gems/documentcloud/): Rubygem para interactuar con el API DocumentCloud.

# Preguntas?

¿Aún tiene preguntas acerca de cómo colaborar? No dude en [comunicarse con nosotros](javascript:dc.ui.Dialog.contact(\)).

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
