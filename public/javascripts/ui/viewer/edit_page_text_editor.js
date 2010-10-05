dc.ui.EditPageTextEditor = dc.Controller.extend({
  
  id : 'edit_page_text_container',
  
  flags : {
    open: false
  },
  
  callbacks : {
    '.edit_page_text_confirm_input.click' : 'confirmEditPageText'
  },
  
  originalPageText: {},
  pageText: {},
  
  constructor : function(opts) {
    this.base(opts);
    _.bindAll(this, 'confirmEditPageText', 'cachePageText');
  },

  toggle : function() {
    if (this.flags.open) {
      this.close();
    } else {
      dc.app.editor.closeAllEditors();
      this.open();
    }
  },
  
  findSelectors : function() {
    this.$s = {
      guide : $('#edit_page_text_guide'),
      guideButton: $('.edit_page_text.button'),
      page : $('.DV-text'),
      textContents : $('.DV-textContents'),
      pages : $('.DV-pages'),
      viewerContainer : $('.DV-docViewer-Container'),
      header : $('#edit_page_text_container'),
      container : null,
      saveButton : $('.edit_page_text_confirm_input')
    };
    
    this.viewer = DV.viewers[_.first(_.keys(DV.viewers))];
    this.imageUrl = this.viewer.schema.document.resources.page.image;
  },
  
  open : function() {
    this.originalPageText = {};
    this.pageText = {};
    this.flags.open = true;
    this.render();
    this.viewer.api.enterEditPageTextMode();
  },
  
  render : function() {
    this.findSelectors();
    $(this.el).html(JST['viewer/edit_page_text']({}));
    this.$s.viewerContainer.append(this.el);
    if (this.viewer.state != 'ViewText') {
        this.viewer.open('ViewText');
    }
    this.$s.pages.addClass('edit_page_text_viewer');
    this.$s.container = $(this.el);
    this.findSelectors();
    
    this.$s.guideButton.addClass('open');
    this.$s.guide.fadeIn('fast');
    this.$s.saveButton.attr('disabled', true);
    this.$s.header.removeClass('active');
    this.$s.textContents.attr('contentEditable', true);
    this.$s.textContents.addClass('DV-editing');
    
    this.setCallbacks();
  },

  setCallbacks : function() {
    
    this.$s.textContents.bind('keyup', this.cachePageText);
    this.$s.textContents.bind('change', this.cachePageText);
    this.$s.textContents.bind('blur', this.cachePageText);
    this.base();
  },
  
  getPageNumber : function() {
    return currentDocument.api.currentPage();
  },
  
  getPageText : function(pageNumber) {
    pageNumber = pageNumber || this.getPageNumber();
    
    return currentDocument.api.getPageText(pageNumber);
  },
  
  confirmEditPageText : function() {
    var modifiedPages = this.getChangedPageTextPages();
    var documentId = parseInt(this.viewer.api.getId(), 10);

    $('input.edit_page_text_confirm_input', this.el).val('Saving...').attr('disabled', true);
    
    $.ajax({
      url       : '/documents/' + documentId + '/save_page_text',
      type      : 'POST',
      data      : { modified_pages : JSON.stringify(modifiedPages) },
      dataType  : 'json',
      success   : _.bind(function(resp) {
        this.viewer.api.resetPageText(true);
        this.close();
      }, this)
    });
  },
  
  cachePageText : function() {
    var pageNumber = this.getPageNumber();
    var pageText = Inflector.trim(this.extractText(this.$s.textContents));
    if (!(pageNumber in this.originalPageText)) {
      this.originalPageText[pageNumber] = this.getPageText(pageNumber);
    }
    if (pageText != this.originalPageText[pageNumber]) {
      this.$s.header.addClass('active');
      this.$s.saveButton.removeAttr('disabled');
    }
    this.pageText[pageNumber] = pageText;
    currentDocument.api.setPageText(pageText, pageNumber);
    console.log(['cachePageText', pageText]);
  },
  
  extractText : function(elems) {
    var ret = "", elem;

    _.each(elems, _.bind(function(elem) {
      if (elem.nodeType == 3 || elem.nodeType == 4) {
        // Get the text from text nodes and CDATA nodes
        ret += elem.nodeValue;
      } else if (elem.nodeType != 8) {
        // Traverse everything else, except comment nodes
        ret += this.extractText(elem.childNodes) + '\n';
      }
    }, this));

    return ret;
  },
  
  getChangedPageTextPages : function() {
    var modifiedPages = {};
    _.each(this.pageText, _.bind(function(pageText, pageNumber) {
      if (this.originalPageText[pageNumber] != pageText) {
        modifiedPages[pageNumber] = pageText;
      }
    }, this));
    
    return modifiedPages;
  },
  
  close : function() {
    if (this.flags.open) {
      this.flags.open = false;
      this.$s.guideButton.removeClass('open');
      this.$s.guide.fadeOut('fast');
      this.$s.pages.removeClass('edit_page_text_viewer');
      this.$s.textContents.attr('contentEditable', false);
      this.$s.textContents.removeClass('DV-editing');
      $(this.el).remove();
      this.viewer.api.leaveEditPageTextMode();
      this.base();
    }
  }

});