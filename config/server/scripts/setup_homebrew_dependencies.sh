#!/bin/bash

#################################
# INSTALL HOMEBREW PACKAGES
#################################
echo BEGINNING HOMEBREW SETUP

HOMEBREW_PACKAGES='
poppler
libpng
freeimage
freetype
git
'

echo $HOMEBREW_PACKAGES | xargs brew install

# Install GraphicsMagick along with dependencies
brew install --with-libtiff --with-ghostscript graphicsmagick

# Install development version of Tesseract
brew install --devel tesseract

# Install PDFShaver dependencies
brew install --HEAD https://raw.githubusercontent.com/knowtheory/homebrew/45606ddde3fdd657655208be0fb1a065e142a4f1/Library/Formula/pdfium.rb
echo HOMEBREW SETUP COMPLETED SUCCESSFULLY
