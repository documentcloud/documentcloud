# Publicando Documentos, Páginas, Notas y Conjuntos de Documentos

Listo para compartir sus documentos con los lectores? Ya sea por la incorporación de nuestro visor personalizado o usar oEmbed, puede publicar documentos individuales, integrar un conjunto de documentos que los lectores pueden navegar, o incrustar una sola página o una nota de cualquier documento.

## Contents

* [Haciendo documentos públicos](#public)
* [Enlace a un documento, página o nota](#linking)
* Generar códigos embed:
  * [Documentos](#embed-document)
  * [Páginas](#embed-page)
  * [Notas](#embed-note)
  * [Grupo de Documentos](#embed-set)
* [WordPress Shortcodes](#wordpress)
* [oEmbed service](#oembed)

<a name="public"></a>
# Haciendo documentos públicos

Antes de publicar un documento, página, nota o conjunto de documentos, usted querrá asegurarse de que el documento o los documentos son públicos. Haga público un documento mediante la opción "Nivel de Accesol" (en el menú "Editar") o mediante la selección de una fecha de publicación (en el menú "Publicar").

<a name="linking"></a>
# Enlace a un documento, página o nota

La forma más sencilla de compartir su trabajo en DocumentCloud con los lectores es publicar un enlace a un documento. Puede modificar la dirección URL para que el documento abierto en una página o una nota específica. Siga estos formatos de URL:

### Documento completo:

`https://www.documentcloud.org/documents/282753-lefler-thesis.html`

### Documento abierto a una página específica:

`https://www.documentcloud.org/documents/282753-lefler-thesis.html#document/p22`

### Documento abierto a una nota específica:

`https://www.documentcloud.org/documents/282753-lefler-thesis.html#document/p57/a42283`

Para encontrar la dirección URL (o enlace permanente) de una nota, abra la nota y seleccione el icono de enlace <span class="icon permalink" style="padding-left:16px;position:relative;top: -2px;">&#65279;</span>. Barra de direcciones del navegador se actualiza para mostrar la URL completa de la anotación.

<a name="embed-document"></a>
# Publicando documentos individuales

Para publicar cualquier documento de DocumentCloud, puede descargar una copia independiente del visor, o generar, copiar, y pegar un código de inserción sencillo para ese documento. Le recomendamos incrustar un código que vincule a DocumentCloud en la mayoría de los documentos. Las siguientes instrucciones asumen que tiene conocimiento básico de HTML, pero hemos tratado que el proceso de incorporación/incrustación sea lo sencillo posible. 

Nosotros mantenemos una lista de algunos de nuestros documentos incrustados favoritos como ejemplos de cómo podrían incrustar documentos las salas de redacción.

## <span id="choose_size">Revise su metadatos</span>

![Embed Menu](/images/help/embed_menu.png)

Antes de incrustar un documento en su sitio, le recomendamos que complete un par de datos adicionales acerca del documento. Abra el documento para revisar una vez más el **título del documento**, **la descripción**, **la fuente y las notas públicas**. Si todo está a su gusto, está listo para continuar.

Seleccione un documento, abra el menú "Publicar" y haga clic en "Incrustar Marco de Revisión" o haga clic en el documento con el botón derecho del ratón y seleccione "Incrustar Marco de Revisión".

Aparecerá un cuadro de diálogo que le pedirá que complete dos datos adicionales: **URL de Artículo Relaciónado**, **URL Publicado**. El URL del reportaje relacionado es la ubicación del reportaje que utiliza el documento como material de fuente –  añadir este URL significa que los lectores que encuentren primero el documento también podrán encontrar sus reportajes. El URL publicado es la página donde se ha insertado el documento. La mayoría de los usuarios no tendrán que proporcionar esta información –  [Pixel Ping](http://www.propublica.org/nerds/item/pixel-ping-a-nodejs-stats-tracker) por lo general nos puede decir donde está incrustado el documento. Sin embargo, si un documento podría  encontrarse por medio de varios URLs, usted puede especificar cual URL debemos enviar a los usuarios si encuentran el documento por medio de una búsqueda de DocumentCloud.

En el primer paso, usted también verá una casilla de verificación con la opción de que el documento sea público, si es que no lo es todavía. Mientras que es posible pegar el código de inserción antes de que el documento se haga público, no comenzará a funcionar hasta que el documento se haya publicado en DocumentCloud. 

Si aún no está listo para hacer el documento público, puede programarlo para que se publique en una fecha futura. Haga clic en "Set Publication Date" en el menú "Publish" y seleccione la fecha y la hora que desea que el documento se haga público. Esto es útil si usted ya sabe cuándo se publicará su artículo, o si se publicará en la madrugada.

## <span id="template">Configurando el visor de documentos</span>

Dependiendo de cómo desea que se muestre el documento en su sitio web, usted tiene dos opciones: puede crear una plantilla para un visor de **página completa**, con su propio logotipo, enlaces, análisis de datos y publicidad, o puede integrar un visor de **tamaño fijo** directamente en el interior un artículo. También puede incrustar varios visores de **tamaño fijo** en una sola página. 

Para crear una plantilla de página completa, utilice una plantilla de ancho fluido, con un encabezado - el visor ocupará el resto de la página.  Asegúrese de que la plantilla tenga un doctype correcto, y que es pasa la [validación de HTML](http://validator.w3.org/). Las plantillas que hacen que Internet Explorer entre en quirks mode causarán que el visor se muestre incorrectamente. 

Aquí hay algunos ejemplos activos que vale la pena visitar: [NewsHour](http://www.pbs.org/newshour/rundown/stevens-testimony.html), [Arizona Republic](http://www.azdatapages.com/sb1070.html), [Chicago Tribune](http://media.apps.chicagotribune.com/docs/obama-subpoena.html), [ProPublica](http://www.propublica.org/documents/item/magnetars-responses-to-our-questions), pero hay [muchos más](/featured/).

<img src="/images/help/newshour.jpg" class="full_line" />

Si opta por integrar un visor de **tamaño fijo**, establezca la anchura y  la altura en píxeles. También puede intercambiar la barra lateral y la pestaña de texto. Recomendamos ocultar la barra lateral en los visores de documentos que son más estrechos que 800 píxeles. Si usted está incrustando documentos escritos a mano o documentos con resultados insatisfactorios de OCR, suele ser una buena idea ocultar la pestaña de texto. Utilice el enlace "preview the document viewer" para ver un ejemplo del visor presentado de acuerdo a sus especificaciones. 

## <span id="embed">Copie y pegue el código</span>

Haga clic en el botón "Next" para continuar con el paso 3, y veráx el código de inserción: un fragmento de código HTML que se puede pegar en cualquier página web para crear un visor de documentos. El código se asemejará a lo siguiente: 

    <div id="viewer-10-general-report"></div>
    <script src="//assets.documentcloud.org/viewer/loader.js"></script>
    <script>
      DV.load('https://www.documentcloud.org/documents/10-general-report.js', {
        container : '#viewer-10-general-report'
      });
    </script>

Coloque el código de inserción en su página, en la ubicación en la que desea que aparezca el visor. La próxima vez que se cargue la página, el visor deberá estar en funcionamiento. 

## <span id="intouch">Manténgase en contacto</span>

[¡Cuéntenos acerca de sus reportajes!](javascript:dc.ui.Dialog.contact(\))

<a name="embed-page"></a>
# <span id="page_embed">Códigos Integrar para una Sola Página</span>

![Embed Page Menu](/images/help/embed_page_menu.png)

DocumentCloud ofrece un visor ligero, adaptive que pone de relieve una sola página (incluyendo las anotaciones) con un mínimo de cromo extra. Está diseñado para funcionar igual de bien en móviles y de escritorio y es perfecto para su uso en aplicaciones de noticias personalizadas o de formato largo presentaciones de periodismo. Próximamente: opciones para permitir que los lectores tengan acceso a todas las páginas en el documento o leer el texto extraído.

Incorporación de una página es similar a la incorporación de un documento: Seleccione un documento, abra el menú "Publicar" y haga clic en "Incrustar una página." Alternativamente, haga clic en el documento y seleccione "Incrustar una página."

En el cuadro de diálogo que aparece a continuación, seleccione el número de la página para incrustar. Una vista previa de la página de inserción aparece; si quieres una página diferente, puede seleccionarlo en el menú.

Haga clic en "Siguiente" para pasar al paso 2 y generar el código HTML empotrable. He aquí una muestra de lo que se verá así:

    <div class="DC-embed" data-version="1.1">
      <div style="font-size:10pt;line-height:14pt;">
        Page 57 of <a class="DC-embed-resource" href="https://www.documentcloud.org/documents/282753-lefler-thesis.html#document/p57" title="View entire Lefler Thesis on DocumentCloud in new window or tab" target="_blank">Lefler Thesis</a>
      </div>
      <img src="//www.documentcloud.org/documents/282753/pages/lefler-thesis-p57-normal.gif" srcset="//www.documentcloud.org/documents/282753/pages/lefler-thesis-p57-normal.gif 700w, //www.documentcloud.org/documents/282753/pages/lefler-thesis-p57-large.gif 1000w" alt="Page 57 of Lefler Thesis" style="max-width:100%;height:auto;margin:0.5em 0;border:1px solid #ccc;-webkit-box-sizing:border-box;box-sizing:border-box;clear:both">
      <div style="font-size:8pt;line-height:12pt;text-align:center">
        Contributed to
        <a href="https://www.documentcloud.org/" title="Go to DocumentCloud in new window or tab" target="_blank" style="font-weight:700;font-family:Gotham,inherit,sans-serif;color:inherit;text-decoration:none">DocumentCloud</a> by
        <a href="https://www.documentcloud.org/public/search/Account:2258-ted-han" title="View documents contributed to DocumentCloud by Ted Han in new window or tab" target="_blank">Ted Han</a> of
        <a href="https://www.documentcloud.org/public/search/Group:dcloud" title="View documents contributed to DocumentCloud by DocumentCloud in new window or tab" target="_blank">DocumentCloud</a> &bull;
        <a href="https://www.documentcloud.org/documents/282753-lefler-thesis.html#document/p57" title="View entire Lefler Thesis on DocumentCloud in new window or tab" target="_blank">View document</a> or
        <a href="https://www.documentcloud.org/documents/282753/pages/lefler-thesis-p57.txt" title="Read the text of page 57 of Lefler Thesis on DocumentCloud in new window or tab" target="_blank">read text</a>
      </div>
    </div>
    <script src="//assets.documentcloud.org/embed/loader/enhance.js"></script>

Copie y pegue el código HTML a su sitio para publicar la página.

<a name="embed-note"></a>
# <span id="note_embed">Incrustar una nota de un documento</span>

![Embed Note Menu](/images/help/embed_note_menu.png)

Si usted ha [escrito notas en un documento](/help/notes), puede incrustar cualquier nota directamente en su sitio. Los usuarios pueden insertar notas de cualquier documento que usted tenga privilegios de editar. Para insertar una nota, seleccione un documento y elija la opción "Incrustar una Nota" en el menú "Publicar". 

Se le pedirá que seleccione la nota a insertar, y podrá revisar la nota incrustada. Utilice su propio CSS para controlar la anchura de cualquier nota en su sitio. Su código de inserción HTML se parecerá a esto: 


    <div id="DC-note-237"></div>
    <script src="//assets.documentcloud.org/notes/loader.js"></script>
    <script>
      dc.embed.loadNote('https://www.documentcloud.org/documents/223/annotations/237.js');
    </script>

Copie y pegue el código HTML en su propio sitio. Al hacer clic en el título o la imagen, se abrirá el documento. Los documentos se abrirán en DocumentCloud a menos que los haya publicado en otra parte. Utilizamos pixel ping de adivinar el URL publicado de un documento, de manera que si los usuarios no pueden encuentran el documento de otra manera, puede que usted tenga que añadir el URL publicado manualmente.

<a name="embed-set"></a>
# <span id="docset">Incrustando un conjunto de documentos</span>

![Embed Search Menu](/images/help/embed_search_menu.png)

Si prefieres incrustar un conjunto de documentos, DocumentCloud puede proporcionarle el código HTML para este propósito también. Los lectores serán capaces de buscar o filtrar a través de tantos documentos como desee compartir con ellos. 

Puede incrustar cualquier conjunto de documentos, ya sea que usted los haya subido o no: cualquier documento que ya ha sido publicado por su aportador se abrirá usando el URL con el que se publicó originalmente. 

Para empezar, encuentre un conjunto de documentos que desee incrustar - ya sea mediante la selección de un proyecto o mediante la ejecución de una búsqueda. Nota: documentos públicos futuros añadidos al proyecto o que coincidan con los criterios de búsqueda, se añadirán a su conjunto de documentos incrustado. Abra el menú "Publish" y seleccione "Incrustar Lista de Documentos". Usted verá un cuadro de diálogo que le permitirá configurar el conjunto incrustado:

 * Proporcione **un título** a mostrar arriba del conjunto incrustado de documentos;
 * **Organice** los documentos alfabéticamente, usando la fecha de carga, o por longitud;
 * Establezca el número de documentos que desea mostrar **por página**, de modo que el conjunto incrustado se adapte a la altura y la anchura del espacio que tiene disponible;
 * Oculte o muestre una **barra de búsqueda**, que permita a sus lectores buscar dentro del conjunto incrustado.

Una vez que usted se sienta cómodo con la configuración, revise el conjunto de documentos incrustado en vista previa. Si la vista previa se ve bien, copie y pegue el código de inserción HTML.  Este es un ejemplo de cómo se debe ver el código de inserción:

    <div id="DC-search-projectid-8-epa-flouride"></div>
    <script src="//assets.documentcloud.org/embed/loader.js"></script>
    <script>
      dc.embed.load('https://www.documentcloud.org/search/embed/', {
        q: "projectid: 8-epa-flouride",
        container: "#DC-search-projectid-8-epa-flouride",
        order: "title",
        per_page: 12,
        search_bar: true,
        organization: 117
      });
    </script>

Pegue el código en su página web, y el conjunto de documentos aparecerá.

<img src="/images/help/search_embed.png" class="full_line" />

Haga clic en cualquier documento para abrirlo. Si ha publicado el documento en su página web previamente,  deberíamos haber detectado su URL automáticamente, y se abrirá con ese URL. Si el documento es público, pero aún no se ha publicado, se abrirá en DocumentCloud.org. Si está seguro de que usted ha publicado un documento, pero aun así se abre en DocumentCloud.org, abra el menú "Edit", haga clic en "URL Publicado", y establezca manualmente el URL con el que se ha publicado el documento.

<a name="wordpress"></a>
# <span id="docset">WordPress Shortcodes</span>

Los usuarios que publican a través de WordPress pueden instalar un plugin que permite incorporar recursos DocumentCloud utilizando [shortcodes](https://codex.wordpress.org/Shortcode_API).

Descargue el plugin DocumentCloud en su [página de plugin para WordPress](https://wordpress.org/plugins/documentcloud/). Instalar y activar de acuerdo a las instrucciones.

Una vez activado, puede incrustar recursos con un shortcode, que se puede agarrar de la última etapa de nuestro asistente de embed. También puede pasar parámetros adicionales para controlar el tamaño y los atributos del embed.

Por ejemplo, si desea incrustar un documento a 800px de ancho, pre-desplazado a la página 3:

    [documentcloud url="https://www.documentcloud.org/documents/282753-lefler-thesis.html" width="800" default_page="3"]

Si usted no indica una anchura (o manualmente deshabilitar anchos de adaptive con `responsive="false"`), el documento automáticamente estrecho y ampliar para llenar el ancho disponible.

Para una página, utilice cualquier URL específica de la página:

    [documentcloud url="https://www.documentcloud.org/documents/282753-lefler-thesis.html#document/p22"]

Para una nota, utilice cualquier URL-nota específica:

    [documentcloud url="https://www.documentcloud.org/documents/282753-lefler-thesis.html#document/p1/a53674"]

Una lista de todos los parámetros que puede utilizar con el código corto está disponible en [la página del plugin](https://wordpress.org/plugins/documentcloud/).

<a name="oembed"></a>
# <span id="docset">oEmbed Service</span>

oEmbed es un estándar Web para proporcionar el contenido embebido en un sitio a través de una petición a la URL del recurso. Si un sistema de gestión de contenidos apoya oEmbed, sólo tiene que pegar en la URL de un recurso DocumentCloud, y el CMS se ha podido ir a través de nuestro [oEmbed API] [] e incrustarlo. Consulte con el administrador de sistemas de la organización acerca de si su CMS apoya oEmbed.

### Ejemplo URL documento para oEmbed

    https://www.documentcloud.org/documents/1234-document-name.html

### Ejemplo página URL para oEmbed

    https://www.documentcloud.org/documents/1234-document-name/pages/2.html

### Ejemplo URL nota para oEmbed

    https://www.documentcloud.org/documents/1234-document-name/annotations/220666.html

# Preguntas?

¿Aún tiene preguntas acerca de la publicación e incrustación? No dude en [comunicarse con nosotros](javascript:dc.ui.Dialog.contact(\)).

[oEmbed API]: https://www.documentcloud.org/help/api#oembed
