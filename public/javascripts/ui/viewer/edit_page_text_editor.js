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
  
  setCurrentPageText : function(pageText) {
    currentDocument.api.setPageText(pageText);
    currentDocument.api.redraw();
  },
  
  confirmEditPageText : function() {
    dc.ui.Dialog.confirm('Reordering pages takes a few minutes to complete.<br /><br />Are you sure you want to continue?', _.bind(function() {
      $('input.edit_page_text_confirm_input', this.el).val('Saving...').attr('disabled', true);
      var pageOrder = this.serializePageOrder();
      this.viewer.api.reorderPages(pageOrder, {
        success : function(model_id, resp) {
          window.opener && window.opener.Documents && window.opener.Documents.get(model_id).set(resp);
          dc.ui.Dialog.alert('This process will take a few minutes.<br /><br />This window must close while pages are being reordered and the document is being reconstructed.', { 
            onClose : function() {
              window.close();
            }
          });
        }
      });
      return true;
    }, this));
  },
  
  cachePageText : function() {
    var pageNumber = this.getPageNumber();
    var pageText = this.$s.textContents.text();
    this.pageText[pageNumber] = pageText;
    currentDocument.api.setPageText(pageText, pageNumber);
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