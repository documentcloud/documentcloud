# Solución de problemas de documentos

Siempre estamos (con su ayuda) descubriendo nuevas y diferentes maneras de descomponer nuestro importador de documentos. Estas son buenas noticias, ya que es una de las maneras que usted está ayudando a mejorar DocumentCloud. En algunos casos, la solución a un problema de importación de un documento es tan simple como abrir el documento en Adobe Acrobat o Vista previa de Apple, optimizarlo para uso web y volver a guardarlo.

En Vista Previa, abra el PDF y elija "Archivo> Imprimir". Cuando se abra el cuadro de diálogo, haga clic en el menú "PDF" en la esquina inferior izquierda, y seleccione "Guardar como PDF".

En Acrobat, abra el PDF y seleccione "Avanzadas> Optimizador de PDF". Verá una ventana con una lista de categorías de optimizaciones a mano izquierda. Haga clic en la lista y asegúrese de que todas las optimizaciones posibles estén seleccionadas. Cuando esté listo, haga clic en "Aceptar" para guardar el archivo PDF.

<img src="/images/help/pdf_optimizer.jpg" class="full_line" />

## Ruido en los documentos

Muy de vez en cuando, nos encontramos con que los documentos que contienen alteraciones de gobierno se verán como si estuvieran cubiertos en una niebla gris oscura de píxeles. [GraphicsMagick](http://www.graphicsmagick.org/), el cual se utiliza para manipular las imágenes de cada página del documento, parece a veces extender estas alteraciones en la página. Cambios recientes en [Ghostscript](http://pages.cs.wisc.edu/~ghost/doc/GPL/gpl900.htm) parecen haber resuelto el problema en su mayor parte, pero si usted todavía está viendo ruido en los documentos, hemos descubierto que volver a guardar un documento en Acrobat o Vista previa puede solucionar el problema. Si eso no funciona, [comuníquese con nosotros](javascript:dc.ui.Dialog.contact(\)) y le ayudaremos a resolver el problema.

## No aparece el texto

Si tiene texto de alta calidad incrustada en el PDF, no queremos reemplazar su texto con una versión de menor calidad, por lo que cuando se carga un documento, el sistema busca algunas pistas de que un documento ya contiene texto. Sin embargo, en ocasiones los documentos dan señales mixtas. Si usted tiene un documento que no se digitalizó en lo absoluto (con OCR), comuníquese con nosotros. Por un lado, podemos ayudarle a digitalizar el documento. Por otra parte, queremos saber cuándo nuestro sistema no está funcionando bien.

## <span id="encrypted">Documentos encriptados o protegidos</span>

No es sorprendente que las agencias del gobierno publiquen documentos que utilizan herramientas de restricción de usuarios  o  de monitoreo en archivos PDF. DocumentCloud puede procesar algunos archivos PDF que han sido bloqueados o protegidos por contraseña, pero si no podemos abrir su documento, aún podría navegar dichas restricciones. Puede que sea capaz de abrir un documento por sí mismo con [qpdf][]. Si qpdf no está funcionando, averigüe si su sistema operativo o el diálogo de impresión incluyen la opción "Imprimir en archivo" (Print to file) o "Imprimir a PDF” (Print PDF). Usted podrá "imprimir" un nuevo documento con el cual podría  trabajar en DocumentCloud.

## <span id="more">Más herramientas</span>

¿No tiene acceso a Acrobat o Vista previa? Hay todo [un mundo de maravillosos editores de archivos PDF](http://en.wikipedia.org/wiki/List_of_PDF_software) por ahí (y no hay escasez de los que no son tan buenos), pero estos son algunos de los que hemos probado:

 * [pdftk][]: Si tiene confianza(o le gustaría sentirse confiado) de trabajar con herramientas de línea de comandos,  [pdftk][] es un gran recurso. Usted puede dividir un documento en varios, combinar varios documentos en uno solo, cambiar el orden de las páginas, y más.
 * [qpdf][]: Otra excelente herramienta de línea de comandos, [qpdf][] podrá, entre otras cosas, descifrar archivos PDF bloqueados y optimizarlos para la web (mediante linealización).
 * [PDFill][]: Si tiene Windows y aún no tiene Acrobat (o simplemente Acrobat Reader), podría obtener provecho de las herramientas de PDF de [PDFill][] (por medio de Lifehacker). Tendrá que pagar $ 19.99 para deshacerse de los anuncios, pero incluso en la versión gratuita podrá girar, combinar, dividir y añadir  marcas de agua a su documento. El proceso de instalación es un poco confuso: usted tiene que instalar la suite completa, que incluye tres programas diferentes. Para girar un documento, utilice PDF Tools, en vez de PDF Editor.

¿Aún tiene problemas con un documento? No dude en [comunicarse con nosotros](javascript:dc.ui.Dialog.contact(\)).


[pdftk]: http://www.accesspdf.com/pdftk/
[PDFill]: http://pdfill.com/
[qpdf]: http://qpdf.sourceforge.net/
