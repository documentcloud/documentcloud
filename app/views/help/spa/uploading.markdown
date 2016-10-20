# Carga de documentos

Como usuario DocumentCloud, usted quiere construir una colección de archivos a la investigación, analizar, comentar y publicar con nuestros incrusta. Afortunadamente, la carga de archivos - si usted tiene un puñado o varios miles - es fácil.

## Contenido

* Carga:
  * [Sube a través de Workspace](#upload-workspace)
  * [Sube a través de API](#upload-api)
* Details and Options:
  * [OCR Idiomas](#ocr-languages)
  * [Formatos de Archivo](#file-formats)
  * [Tamaño de Archivo](#file-size)

<a name="upload-workspace"></a>
## Sube a través de Workspace

Hay dos formas de subir en el workspace:

* Arrastre y suelte los documentos en el propio espacio de trabajo.
* Alternativamente, haga clic en el botón "Documentos nuevos" en la barra lateral y seleccione los archivos que desea cargar. En Windows, mantenga presionada la tecla `ctrl` para seleccionar más de un documento. En un Mac, mantenga presionada `command`. *Nota: solo se pueden cargar múltiples documentos a la vez usando navegadores que no sean Internet Explorer.*

<img src="/images/help/upload_dialog.png" class="full_line" />

El cargador le sugerirá un título para el documento basado en su nombre de archivo. Puede editar el título antes de continuar, o puede editar el título, más otros metadatos después se carga el documento. Haga clic en el icono de lápiz para agregar una descripción y la fuente para cada documento y establecer el nivel de acceso (por defecto es privado). Si los archivos que estamos introduciendo deben compartir una fuente y la descripción, haga clic en "Aplicar a todos los archivos."

Cuando esté listo, haga clic en "Subir." El diálogo se cerrará cuando todos los archivos se han subido. Antes de poder trabajar con ellos, sin embargo, DocumentCloud debe procesar los documentos para el visor de documentos. La cantidad de tiempo requerido para procesar un documento varía en función de su tamaño, su tipo y la cantidad actual de la actividad de la plataforma.

Para ser notificado por correo electrónico cuando se acaban sus documentos, haga clic en la casilla de verificación. Si va a subir muchos documentos grandes a la vez, háganoslo saber para que podamos garantizar que hay suficientes recursos informáticos disponibles.

Para ver todos los documentos que has subido, haga clic en el enlace "[Tus Documentos][]" en la parte superior izquierda.

<a name="upload-api"></a>
## Sube a través de API

Los usuarios que quieran subir muchos cientos o miles de documentos o automatizar los envíos de documentos pueden querer considerar el uso de la [DocumentCloud API][]. [El método][] `upload.json` prevé que pasa en el nombre del archivo, de la identificación de proyectos y muchos otros parámetros con el propio archivo. También permite archivos directamente desde una URL.

<a name="ocr-languages"></a>
## OCR Idiomas

Si el archivo ha texto incrustado, extractos DocumentCloud y lo guarda. Si no es así (como en un archivo de imagen o un archivo PDF de un documento escaneado), DocumentCloud utiliza el reconocimiento óptico de caracteres ([OCR][]) de software para tratar de identificar el texto. Para ello, nuestra plataforma se basa en el código abierto [Tesseract][] biblioteca.

A través de Tesseract, DocumentCloud Actualmente soporta más de 20 idiomas para OCR, incluido el árabe, español y ruso. Puede seleccionar un idioma predeterminado en la pestaña "Cuentas" en el Workspace. Elija un idioma en el menú desplegable "Documentos nuevos".

<a name="file-formats"></a>
## Formatos de Archivo

La mayoría de los usuarios DocumentCloud trabajar con archivos PDF, pero nuestro software pueden tomar cualquier tipo de archivo que [LibreOffice][] apoyos. Esto incluye Microsoft Word, Excel y PowerPoint; Archivos de texto enriquecido; y varios archivos de imagen incluyendo TIFF, PNG, GIF y JPEG.

Al cargar, todos los archivos que no son PDF se convierten a PDF para su uso en DocumentCloud.

<a name="file-size"></a>
## Tamaño de Archivo

El tamaño máximo de archivo para una carga de DocumentCloud es de 400 MB. Sin embargo, los archivos que grandes son difíciles de procesar, y es probable que obtener mejores resultados si a optimizar documentos de gran tamaño (algo más de 10 MB) antes de cargarlas. En un Mac, [usar Vista previa para reducir el tamaño de su archivo][]. Adobe Acrobat [funciona tan bien][]. ¿No tiene Acrobat o de vista previa? Echa un vistazo a nuestros consejos para la solución de [problemas documentos][] para más recursos.


¿Todavía tiene preguntas sobre la carga de documentos? No dude en [contáctenos][].

[LibreOffice]: http://www.libreoffice.org/
[usar Vista previa para reducir el tamaño de su archivo]: http://www.ehow.com/how_4499823_reduce-file-size-pdf-using.html
[funciona tan bien]: http://www.ehow.com/how_5874491_decrease-size-pdf.html
[OCR]: http://en.wikipedia.org/wiki/Optical_character_recognition
[Tesseract]: http://code.google.com/p/tesseract-ocr/
[problemas documentos]: /help/troubleshooting
[DocumentCloud API]: /help/api
[El método]: /help/api#upload-documents
[Tus Documentos]: javascript:Accounts.current().openDocuments()
[contáctenos]: javascript:dc.ui.Dialog.contact()
