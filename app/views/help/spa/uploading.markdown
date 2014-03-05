# Cargando documentos

La mayoría de usuarios de DocumentCloud están usando archivos PDF, pero nuestro software puede trabajar con cualquier tipo de archivo compatible con OpenOffice: documentos en Microsoft Word, RTF y archivos de OpenDocument funcionarán bien. Los archivos de imágenes, como tiff, jpeg y png también funcionarán.

Si abre un proyecto antes de comenzar la carga, sus nuevos documentos se añadirán al proyecto que ha abierto.

Para cargar uno o varios documentos, haga clic en el botón "Documentos Nuevos" en la barra lateral y seleccione los archivos que desea subir. Mantenga presionada la tecla Ctrl para seleccionar más de un documento. *Nota: solo se pueden cargar múltiples documentos a la vez usando navegadores que no sean Internet Explorer.*

<img src="/images/help/upload_dialog.png" class="full_line" />

El cargador le sugerirá un título para el documento, basado en el nombre del archivo. Usted puede editar el título antes de continuar, pero también podrá de editar los metadatos de cada documento después de haberlos cargado. Considere proporcionar datos adicionales acerca de cada documento: haga clic en el icono de lápiz para ampliar una forma detallada, donde puede añadir una descripción y fuente/origen de cada documento y establecer el nivel de acceso. Si los archivos que está cargando deben compartir una fuente y descripción, haga clic en el enlace titulado: "aplicar a todos los archivos."

Cuando esté listo, haga clic en "Subir”. El diálogo se cerrará cuando todos los archivos se hayan cargado. Antes de poder trabajar con ellos, DocumentCloud tiene que terminar de procesar sus documentos para poder verlos en nuestro visor de documentos. La mayoría de los documentos son procesados en menos de 30 minutos, pero el tiempo que se tarda en procesar los documentos depende en gran medida de cuántos usuarios están trabajando al mismo tiempo. Si desea que se le notifique cuando el grupo de documentos termine de ser procesado, haga clic en la casilla correspondiente y nosotros le enviaremos un e-mail cuando estén listos. Si está cargando muchos documentos grandes a la vez, notifíquenos para asegurarnos de que hay suficiente potencia de cálculo disponible.

Usted puede obtener mejores resultados si optimiza documentos de gran tamaño (de más de 10 MB) antes de cargarlos. En Mac, [utilice Vista Previa (Preview) para reducir el tamaño de su archivo](http://www.ehow.com/how_4499823_reduce-file-size-pdf-using.html). Adobe Acrobat [tan bien funciona](http://www.ehow.com/how_5874491_decrease-size-pdf.html). ¿No tiene Acrobat o Vista Previa? Visite nuestra página de consejos para [solución de problemas de documentos](/help/troubleshooting) para obtener más recursos.

## API

También ofrecemos una [API para cargar conjuntos](/help/api) de documentos. La información de nuestro API sólo es accesible para usuarios registrados.

## Reconocimiento óptico de caracteres (OCR)

Estamos utilizando un software de OCR llamado [Tesseract](http://code.google.com/p/tesseract-ocr/). Para ser una herramienta absolutamente gratis, es bastante impresionante, pero usted obtendrá mejores resultados con algunos de los servicios de propiedad más elegantes como Abbyy o Nuance. Si usted tiene acceso a OCR de alta calidad, le recomendamos utilice dicho [OCR](http://en.wikipedia.org/wiki/Optical_character_recognition) en su documento antes de subirlo a DocumentCloud.

¿Qué es OCR? OCR es un software que identifica cada carácter individual o letra en un documento escaneado o en imágenes que de otra manera no tienen información de texto.

## Revisando su trabajo

Para ver todos los documentos que ha subido, haga clic en el enlace ["Tus Documentos"](javascript:Accounts.current(\).openDocuments(\)) en la parte superior izquierda.

¿Todavía tiene preguntas acerca de la carga de documentos? No dude en [comunicarse con nosotros](javascript:dc.ui.Dialog.contact(\)).
