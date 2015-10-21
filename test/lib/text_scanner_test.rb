# coding: utf-8
require 'test_helper'

class TextScannerTest < ActiveSupport::TestCase

  def test_scanning
    extractor = DC::Import::DateExtractor.new

    date = '2014-12-11'

    # This bit of mal-formed UTF caused the scanner to blow up in the 
    # past
    text = "STALACIÓN ELÉCTRnPROGRAMMACION DOSIS . . . . . . 96\nPROGRAMACIÓN DOSIS CAFÉS . . . GRAMACIÓN AGUA CALIENTE . . . . . . .96\nPROGRAMACIÓN LANZADOR VAPOR AUTOSTEAM\n. .96\nPROGRAMACIÓN DOSIS ESTÁNDAR . . . . . . . . . . . .96\nPROGRAMACIÓN PARÁMETROS DE\nFUNCIONAMIE7\n\nESPAÑOL\n\n7.\n\n7.5\n7.6\n\n8.\n\n83\n\n\fzEÏ- ÉÏËËPN_E'_-'-J'\n\n165\n\nhlﬁlllfï. IN ITIHŸI’\n\n_|\n0\nä\nn.\nU)\nLIJ\n\n \n\n84 \n\n3_Appia1GR_E.qxp\n\n1.\n\n18-01-2006\n\n17:37\n\nDESCRIPCIÓN\n\nPagina 85\nimonelli.com\n\nTel. +39.0733.9501\nFax +39.0733-9502 #{date} lorem ipsum more junk"

    dates = extractor.extract_dates(text)
    assert dates
    occurrence = dates[0][:occurrences][0]
    assert_equal date, text[occurrence.offset, occurrence.length]
  end

end
