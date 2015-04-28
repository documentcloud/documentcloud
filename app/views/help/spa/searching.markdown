# Búsqueda de documentos

Por defecto, la búsqueda encuentra todas las palabras incluidas en el título y el texto completo del documento en sí. Por ejemplo: [John Yoo detainee](#search/John%20Yoo%20detainee). Sin embargo, usted puede pedir que DocumentCloud busque el contenido de campos específicos.

## Búsquedas avanzadas
Incluya términos entre comillas para buscar una frase específica de varias palabras. `"Robert Smith"`

Use boolean operators idioma Inglés `and` and `or` or en junto con paréntesis para agrupar,  y `!`  para excluir términos que no deben estar presentes en los resultados.

Por ejemplo: `(geithner and bernanke)  !madoff`

También puede utilizar `*` para búsquedas de "comodín", por lo que la búsqueda de `J* Brown` resultará en `"Jerry Brown"` y `"John Brown"`.

## <span id="builtin">Búsqueda por medio de campo de metadatos incorporado</span>


Término                    | Descripción
---------------------------|---------------------
title                      | buscará documentos por título, según proporcionado por la persona que lo subió. Por ejemplo: [title: deepwater](#search/title%3A%20deepwater).
source                     | Al cargar un documento, usted tiene la oportunidad de identificar la fuente. Esto proporciona una forma de buscar ese campo. Por ejemplo: [source: supreme]([source: supreme]: #search/source%3A%20supreme)  identificará los documentos atribuidos a la "U.S. Supreme Court” así como "New York State Supreme Court."
description                | Busque la palabra o frase dentro de la descripción de un documento. Por ejemplo: [description: manifesto](#search/description%3A%20manifesto).
account                    | Especifique un ID de cuenta para ver los documentos cargados por un solo usuario. Haga clic en el triángulo de palanca en la esquina superior izquierda de la pestaña "Documents", para ver una lista de todas las cuentas de la organización. Por ejemplo: [account: 7-scott-klein](#search/account%3A%207-scott-klein).
group                      | Si conoce el nombre corto de una organización, puede buscar documentos subidos por cualquier persona en esa sala de redacción. Por ejemplo: [group: chicago-tribune](#search/group%3A%20chicago-tribune). También puede filtrar, dando clic en el nombre de la organización en la lista de documentos.
project                    | Restrinja su búsqueda solamente a los documentos en uno de sus proyectos, tecleando el título. Lo mismo se puede hacer si le da clic al proyecto en la pestaña "Documentos".
projectid                  | Restrinja su búsqueda a un proyecto en particular, por medio del identificador canónico de un proyecto. Es útil para filtrar llamadas a la API (API calls). Usted puede ver este ID abriendo el diálogo de edición del proyecto. Por ejemplo: [projectid: 6-the-financial-crisis](#search/projectid%3A%206-the-financial-crisis)
access                     | Busque sólo los documentos que tienen un nivel de acceso determinado (uno de "public", "private" o "organization"). Por ejemplo, para ver todos sus documentos privados: [access: private](#search/access%3A%20private)
filter                     | Filtre documentos por criterios interesantes (uno de "published", "unpublished", "annotated" o "popular"). Por ejemplo, para ver todos los documentos publicados: [filtro: published](#search/filter%3A%20published)

## <span id="viewing_entities">Visualizando entidades</span>

![OpenCalais Logo](/images/help/opencalais.jpg)

Cada vez que se carga un documento en DocumentCloud enviamos el contenido a [OpenCalais](http://www.opencalais.com/), un servicio que descubre las entidades (personas, lugares, organizaciones, términos, etc) que están presentes en texto sin formato. OpenCalais nos puede decir que "Barack Obama" es la misma persona que "el presidente Obama", "el senador Obama", "Señor Presidente"... e incluso "él" o "su" en cláusulas como "sus propuestas políticas".

Para ver las entidades, seleccione un documento y elija **Ver Entidades**  en el menú **Analyze** ... o haga clic con el lado derecho del mouse en un documento y elija View Entities  en el menú context. Las entidades se mostrarán  en una gráfica que muestra la frecuencia con la que cada entidad aparece en cada página. En esta gráfica, puede ver cuales empresas e individuos tienden a ser mencionados juntos con frecuencia, o qué partes de un documento largo se enfocan en un tema determinado. Pase el ratón sobre cualquier mención (los pequeños cuadros grises) para ver el contexto que lo rodea, y haga clic en los cuadros grises para saltar directamente a esa mención en el documento.

<img alt="" src="/images/help/entities.png" class="full_line" />

## <span id="metadata">Editando y buscando sus propios datos personalizados</span>

DocumentCloud le permite definir y buscar su propio conjunto de datos personalizados (pares clave/valor) asociados a documentos específicos. Para empezar a trabajar con los datos del documento, puede utilizar [la API](#help/api) para agregar datos a sus documentos en conjunto – lo cual es útil si ya tiene una base de datos de información acerca de sus documentos.

Para editar los datos de documentos individuales en el área de trabajo, seleccione los documentos que desea actualizar y elija **Editar Datos del Documento*** en el menú **Editar**...o haga clic con el lado derecho del mouse en un documento y elija **Editar Datos del Documento** en el menú context.

<img alt="" src="/images/help/edit_document_data.png" class="full_line" />

Aparecerá un diálogo que puede utilizar para ver los pares clave/valor existentes, añadir nuevos pares, y eliminar los antiguos.

Para filtrar los documentos por medio de datos que ha añadido, haga clic en la etiqueta (que se muestra en la imagen de arriba), o busque  los pares clave/valor como si se tratara de cualquier otro campo, escribiendo citizen: Pakistan en el cuadro de búsqueda.

Se pueden introducir los mismos tecla varias veces con diferentes valores para un "o" búsqueda. Para buscar todos los ciudadanos de Pakistán o Yemen: `citizen: Pakistan citizen: Yemen`

Si desea filtrar todos los documentos con la clave `citizen`, pero no le importa el valor, puede utilizar: `citizen: *`

Para encontrar todos los documentos que no tienen la clave `citizen` todavía, use: `citizen !`

¿Todavía tiene preguntas acerca de cómo hacer búsquedas? No dude en [comunicarse con nosotros](javascript:dc.ui.Dialog.contact(\)).

Para ver detalles acerca de cómo usar nuestro API de búsqueda, consulte las [instrucciones de API](#help/api).
