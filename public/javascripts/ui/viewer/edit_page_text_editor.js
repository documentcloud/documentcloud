dc.ui.EditPageTextEditor = dc.Controller.extend({
  
  id : 'edit_page_text_container',
  
  flags : {
    open: false
  },
  
  callbacks : {
    '.edit_page_text_confirm_input.click' : 'confirmEditPageText'
  },
  
  constructor : function(opts) {
    this.base(opts);
    _.bindAll(this, 'confirmEditPageText');
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
    this.findSelectors();
    this.flags.open = true;
    // this.viewer.api.enterEditPageTextMode();
    this.render();
    this.$s.guideButton.addClass('open');
    this.$s.guide.fadeIn('fast');
    this.$s.saveButton.attr('disabled', true);
    this.$s.header.removeClass('active');
    this.$s.textContents.attr('contentEditable', true);
    this.$s.textContents.addClass('DV-editing');
  },
  
  render : function() {
    $(this.el).html(JST['viewer/edit_page_text']({}));
    this.$s.viewerContainer.append(this.el);
    this.findSelectors();
    if (this.viewer.state != 'ViewText') {
        this.viewer.open('ViewText');
    }
    this.$s.pages.addClass('edit_page_text_viewer');
    this.$s.container = $(this.el);
    _.defer(_.bind(this.setCallbacks, this));
  },
  
  setCallbacks : function(callbacks) {
    var self = this;
    var $thumbnails = this.$s.thumbnails;
    
    // var pageNumber = currentDocument.api.currentPage();
    // dc.ui.Dialog.prompt('Page Text', currentDocument.api.getPageText(pageNumber), _.bind(function(pageText) {
    //   currentDocument.api.setPageText(pageText);
    //   currentDocument.api.redraw();
    //   return true;
    // }, this));
    this.base(callbacks);
  },
  
  confirmEditPageText : function() {
    dc.ui.Dialog.confirm('Reordering pages takes a few minutes to complete.<br /><br />Are you sure you want to continue?', _.bind(function() {
      $('input.edit_page_text_confirm_input', this.el).val('Reordering...').attr('disabled', true);
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
  
  serializePageOrder : function() {
    var pageOrder = [];

    $('.DV-thumbnail', this.$s.thumbnails).each(function() {
      pageOrder.push($(this).data('pageNumber'));
    });
    
    return pageOrder;
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
      // this.viewer.api.leaveReorderPagesMode();
      this.base();
    }
  }

});