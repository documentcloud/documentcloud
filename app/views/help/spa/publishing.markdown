# Publicando documentos, notas y conjuntos de documentos

¿Esta listo para hacer que sus documentos sean públicos? Publique documentos individuales, incruste un conjunto de documentos que sus lectores puedan navegar, o integre una sola nota en cualquier documento. Antes de publicar una nota, un documento o conjunto de documentos, usted querrá asegurarse de que el documento o los documentos son públicos. Haga público un documento mediante la opción "Nivel de Accesol" (en el menú "Editar") o mediante la selección de una fecha de publicación (en el menú "Publicar").

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

Para ver un ejemplo activo de un documento de tamaño fijo sin barra lateral, vea esta [boleta electoral de WNYC](http://beta.wnyc.org/articles/its-free-country/2010/sep/07/new-nyc-ballot-could-cause-confusion/).

<img src="/images/help/wnyc.jpg" class="full_line" />

## <span id="embed">Copie y pegue el código</span>

Haga clic en el botón "Next" para continuar con el paso 3, y veráx el código de inserción: un fragmento de código HTML que se puede pegar en cualquier página web para crear un visor de documentos. El código se asemejará a lo siguiente: 

    <div id="viewer-10-general-report"></div>
    <script src="http://s3.documentcloud.org/viewer/loader.js"></script>
    <script>
      DV.load('http://www.documentcloud.org/documents/10-general-report.js', {
        container : '#viewer-10-general-report'
      });
    </script>

Coloque el código de inserción en su página, en la ubicación en la que desea que aparezca el visor. La próxima vez que se cargue la página, el visor deberá estar en funcionamiento. 

## <span id="testing">Probando documentos Incrustados</span>

En ocasiones es posible que haya incorporado/incrustado documentos que le gustaría mantener privados mientras que prueba como aparecen en nueva función o diseño de página. Usted puede ver sus documentos incrustados privados -siempre y cuando haya iniciado una sesión- al cambiar el protocolo "http" a "https" en el código de inserción en el URL del documento incrustado (véase la línea que empieza con "DV.load"). **Por favor asegúrese de cambiar sus códigos de inserción a HTTP de nuevo, cuando haga sus documentos públicos.**

## <span id="intouch">Manténgase en contacto</span>

[]¡Cuéntenos acerca de sus reportajes!](javascript:dc.ui.Dialog.contact(\))

# <span id="note_embed">Incrustar una nota de un documento</span>

![Embed Note Menu](/images/help/embed_note_menu.png)

Si usted ha [escrito notas en un documento](/help/notes), puede incrustar cualquier nota directamente en su sitio. Los usuarios pueden insertar notas de cualquier documento que usted tenga privilegios de editar. Para insertar una nota, seleccione un documento y elija la opción "Incrustar una Nota" en el menú "Publicar". 

Se le pedirá que seleccione la nota a insertar, y podrá revisar la nota incrustada. Utilice su propio CSS para controlar la anchura de cualquier nota en su sitio. Su código de inserción HTML se parecerá a esto: 


    <div id="DC-note-237"></div>
    <script src="http://s3.documentcloud.org/notes/loader.js"></script>
    <script>
      dc.embed.loadNote('http://www.documentcloud.org/documents/223/annotations/237.js');
    </script>

Copie y pegue el código HTML en su propio sitio. Al hacer clic en el título o la imagen, se abrirá el documento. Los documentos se abrirán en DocumentCloud a menos que los haya publicado en otra parte. Utilizamos pixel ping de adivinar el URL publicado de un documento, de manera que si los usuarios no pueden encuentran el documento de otra manera, puede que usted tenga que añadir el URL publicado manualmente.

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
    <script src="http://s3.documentcloud.org/embed/loader.js"></script>
    <script>
      dc.embed.load('http://www.documentcloud.org/search/embed/', {
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


¿Aún tiene preguntas acerca de la publicación e incrustación? No dude en [comunicarse con nosotros](javascript:dc.ui.Dialog.contact(\)).
