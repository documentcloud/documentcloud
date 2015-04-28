# Comentarios en documentos: Notas públicas, privadas, y de borrador
![Annotations](/images/help/document_annotations.jpg)

DocumentCloud soporta notas privadas y públicas. Las notas públicas son visibles para cualquier persona que tenga acceso al documento, mientras que las notas privadas son solamente visibles para su autor. Las notas públicas también pueden guardarse como  notas de borrador: las notas de borrador son visibles para cualquier persona con los privilegios necesarios para comentar en un documento, incluyendo [los evaluadores y colaboradores](collaboration), pero dichas notas no se publicarán en el documento. 

Puede escribir notas en cualquier documento abriendo y seleccionando "Añadir una Nota Pública" o "Añadir una nota privada.", según corresponda. El cursor debe cambiar a punto de mira: haga clic y arrastre para seleccionar el área que desea resaltar. Al soltar el cursor, usted podrá añadir y guardar la nota. 

Para hacer notas en una página *en general* en lugar de una región de la página, coloque el cursor de punto de mira en el espacio entre las páginas. Aparecerá una pestaña y una línea punteada - haga clic cerca de la línea para crear una nota que se localice entre las páginas.

<img alt="" src="/images/help/add_page_note.jpg" class="full_line" />

No es posible cambiar el tamaño de una nota. En su lugar, copie el texto contenido, elimine la nota original y dibuje otra pestaña más grande.

![Notes Link](/images/help/notes_link.jpg)

Las notas agregadas a un documento están disponibles en el espacio de trabajo, así como en el documento abierto. Utilice el enlace "Notas" debajo de cualquier imagen miniatura del documento para mostrar todas las notas del documento en el espacio de trabajo. El título de cada nota está conectado a esa misma nota específica en el visor de documentos. Si tiene permiso para editar un documento, también puede editar las notas desde el espacio de trabajo. Si va a modificar las notas en el espacio de trabajo y en el visor de documentos al mismo tiempo, es posible que tenga que actualizar la página para ver los cambios más recientes.

## <span id="markup">Marcado y código HTML en notas</span>

Observe que los cuerpos pueden contener un subconjunto limitado de HTML y de atributos. La siguiente gráfica muestra algunos de los elementos y atributos más comunes. Usted puede encontrar una lista completa debajo de la gráfica.

Elemento                                 | Descripción                              | Atributos
-----------------------------------------|------------------------------------------|-----------
[&lt;a&gt;][a]                           | crea un hipervínculo                     | href
[&lt;img&gt;][img]                       | muestra una imagen                       | src, width, height, alt, align
[&lt;br/&gt;][br]                        | inserta un salto de línea                | –
[&lt;em&gt;][em], [&lt;i&gt;][i]         | hace hincapié en / cursiva el texto      | –
[&lt;strong&gt;][strong], [&lt;b&gt;][b] |texto negritas                            | –
[&lt;u&gt;][u]                           | subraya el texto                         | –
[&lt;blockquote&gt;][blockquote]         | compensaciones texto como una cita       | –
[&lt;table&gt;][table]                   | crea una tabla en la que se insertan las filas (los elementos TR) | summary, width
[&lt;tr&gt;][tr]                         | crea una fila de la tabla para almacenar los datos de la tabla (elementos td) y cabeceras de tabla (elementos th) | –
[&lt;th&gt;][th]                         | crea un encabezado de celda               | abbr, axis, colspan, rowspan, width, scope
[&lt;td&gt;][td]                         | crea una celda de la tabla en una "fila" tr  | abbr, axis, colspan, rowspan, width
[&lt;ol&gt;][ol]                         | crea una lista ordenada numerada          | start, reversed, type
[&lt;ul&gt;][ul]                         | crea es una lista con viñetas sin ordenar | type
[&lt;iframe&gt;][iframe]                 | Un iframe se puede utilizar para insertar páginas web | src, srcdoc, width, height, sandbox

Lista completa de las etiquetas HTML disponibles
[`a`][a], [`abbr`][abbr], [`b`][b], [`bdo`][bdo], [`blockquote`][blockquote], [`br`][br], [`caption`][caption], [`cite`][cite], [`code`][code], [`col`][col], [`colgroup`][colgroup], [`dd`][dd], [`del`][del], [`dfn`][dfn], [`dl`][dl], [`dt`][dt], [`em`][em], [`figcaption`][figcaption], [`figure`][figure], [`h1`][h1], [`h2`][h2], [`h3`][h3], [`h4`][h4], [`h5`][h5], [`h6`][h6], [`hgroup`][hgroup], [`i`][i], [`iframe`][iframe], [`img`][img], [`ins`][ins], [`kbd`][kbd], [`li`][li], [`mark`][mark], [`ol`][ol], [`p`][p], [`pre`][pre], [`q`][q], [`rp`][rp], [`rt`][rt], [`ruby`][ruby], [`s`][s], [`samp`][samp], [`small`][small], [`strike`][strike], [`strong`][strong], [`sub`][sub], [`sup`][sup], [`table`][table], [`tbody`][tbody], [`td`][td], [`tfoot`][tfoot], [`th`][th], [`thead`][thead], [`time`][time], [`tr`][tr], [`u`][u], [`ul`][ul], [`var`][var], [`wbr`][wbr]

[a]:          https://developer.mozilla.org/en/HTML/Element/a
[abbr]:       https://developer.mozilla.org/en/HTML/Element/abbr
[b]:          https://developer.mozilla.org/en/HTML/Element/b
[bdo]:        https://developer.mozilla.org/en/HTML/Element/bdo
[blockquote]: https://developer.mozilla.org/en/HTML/Element/blockquote
[br]:         https://developer.mozilla.org/en/HTML/Element/br
[caption]:    https://developer.mozilla.org/en/HTML/Element/caption
[cite]:       https://developer.mozilla.org/en/HTML/Element/cite
[code]:       https://developer.mozilla.org/en/HTML/Element/code
[col]:        https://developer.mozilla.org/en/HTML/Element/col
[colgroup]:   https://developer.mozilla.org/en/HTML/Element/colgroup
[dd]:         https://developer.mozilla.org/en/HTML/Element/dd
[del]:        https://developer.mozilla.org/en/HTML/Element/del
[dfn]:        https://developer.mozilla.org/en/HTML/Element/dfn
[dl]:         https://developer.mozilla.org/en/HTML/Element/dl
[dt]:         https://developer.mozilla.org/en/HTML/Element/dt
[em]:         https://developer.mozilla.org/en/HTML/Element/em
[figcaption]: https://developer.mozilla.org/en/HTML/Element/figcaption
[figure]:     https://developer.mozilla.org/en/HTML/Element/figure
[h1]:         https://developer.mozilla.org/en/HTML/Element/h1
[h2]:         https://developer.mozilla.org/en/HTML/Element/h2
[h3]:         https://developer.mozilla.org/en/HTML/Element/h3
[h4]:         https://developer.mozilla.org/en/HTML/Element/h4
[h5]:         https://developer.mozilla.org/en/HTML/Element/h5
[h6]:         https://developer.mozilla.org/en/HTML/Element/h6
[hgroup]:     https://developer.mozilla.org/en/HTML/Element/hgroup
[i]:          https://developer.mozilla.org/en/HTML/Element/i
[iframe]:     https://developer.mozilla.org/en/HTML/Element/iframe
[img]:        https://developer.mozilla.org/en/HTML/Element/img
[ins]:        https://developer.mozilla.org/en/HTML/Element/ins
[kbd]:        https://developer.mozilla.org/en/HTML/Element/kbd
[li]:         https://developer.mozilla.org/en/HTML/Element/li
[mark]:       https://developer.mozilla.org/en/HTML/Element/mark
[ol]:         https://developer.mozilla.org/en/HTML/Element/ol
[p]:          https://developer.mozilla.org/en/HTML/Element/p
[pre]:        https://developer.mozilla.org/en/HTML/Element/pre
[q]:          https://developer.mozilla.org/en/HTML/Element/q
[rp]:         https://developer.mozilla.org/en/HTML/Element/rp
[rt]:         https://developer.mozilla.org/en/HTML/Element/rt
[ruby]:       https://developer.mozilla.org/en/HTML/Element/ruby
[s]:          https://developer.mozilla.org/en/HTML/Element/s
[samp]:       https://developer.mozilla.org/en/HTML/Element/samp
[small]:      https://developer.mozilla.org/en/HTML/Element/small
[strike]:     https://developer.mozilla.org/en/HTML/Element/strike
[strong]:     https://developer.mozilla.org/en/HTML/Element/strong
[sub]:        https://developer.mozilla.org/en/HTML/Element/sub
[sup]:        https://developer.mozilla.org/en/HTML/Element/sup
[table]:      https://developer.mozilla.org/en/HTML/Element/table
[tbody]:      https://developer.mozilla.org/en/HTML/Element/tbody
[td]:         https://developer.mozilla.org/en/HTML/Element/td
[tfoot]:      https://developer.mozilla.org/en/HTML/Element/tfoot
[th]:         https://developer.mozilla.org/en/HTML/Element/th
[thead]:      https://developer.mozilla.org/en/HTML/Element/thead
[time]:       https://developer.mozilla.org/en/HTML/Element/time
[tr]:         https://developer.mozilla.org/en/HTML/Element/tr
[u]:          https://developer.mozilla.org/en/HTML/Element/u
[ul]:         https://developer.mozilla.org/en/HTML/Element/ul
[var]:        https://developer.mozilla.org/en/HTML/Element/var
[wbr]:        https://developer.mozilla.org/en/HTML/Element/wbr

## <span id="linking">Vinculando las notas</span>

Vincule cualquier nota directamente: para encontrar el URL (o enlace) de [una nota](http://www.washingtonpost.com/wp-srv/business/documents/fcic-final-report.html#document/p173/a8646), abra la nota y seleccione el icono de enlace. La barra de direcciones de su navegador se actualizará para mostrar la dirección URL completa de la nota. Lo que necesita está localizado después del símbolo # &mdash - [en nuestro ejemplo](http://www.washingtonpost.com/wp-srv/business/documents/fcic-final-report.html#document/p173/a8646), la dirección URL del documento incrustado termina con `#document/p173/a8646`, así que sabemos que la nota está en la página 173. La nota en sí está identificada por una cadena aleatoria (en este caso "a8646").  

También puede incrustar una nota directamente. Visite nuestra página con información sobre [publicación e incrustación](publishing) para obtener más detalles.

## <span id="printing">Imprimiendo notas</span>

![Print Notes][/images/help/print_notes.png]

Es fácil imprimir todas las notas de un documento en particular o de una colección de documentos. Si está en el espacio de trabajo, seleccione los documentos con las notas que le gustaría imprimir, abra el menú "Publicar" y haga clic en "Print Notes". Cuando visualice un documento, usted encontrará el enlace a "Imprimir Notas" en la barra lateral.

## <span id="deleting">Eliminación de Notas</span>

Para eliminar una nota de su documento, abra la nota haciendo clic en él. A continuación, haga clic en el icono de lápiz en la parte superior para acceder al modo de edición. Luego haga clic en el botón Eliminar para eliminar la nota. <strong>Importante:</strong> La eliminación de una nota no se puede deshacer, por lo que proceder con cautela.

# <span id="sections">Agregando Secciones de Navegación</span>

Para ayudar a diferenciar las partes de un documento largo, puede agregar enlaces de navegación a la barra lateral mediante la definición de secciones. Dentro del visor de documentos, haga clic en "Editar Secciones" para abrir el  cuadro de diálogo de Editor de Secciones. Agregue un título, una página de inicio, y una página final en cada sección que desea definir. Utilice los iconos de más y menos para añadir y eliminar filas. Cuando termine, no olvide guardar los cambios.

# <span id="questions">Preguntas?</span>

¿Todavía tiene preguntas sobre como añadir notas a documentos? No dude en [comunicarse con nosotros](javascript:dc.ui.Dialog.contact(\)).
