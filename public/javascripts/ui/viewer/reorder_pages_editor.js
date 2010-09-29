dc.ui.ReorderPagesEditor = dc.Controller.extend({
  
  id : 'reorder_pages_container',
  
  flags : {
    open: false
  },
  
  callbacks : {
    '.reorder_pages_confirm_input.click' : 'confirmReorderPages'
  },
  
  constructor : function(opts) {
    this.base(opts);
    _.bindAll(this, 'confirmReorderPages', 'postOpen');
  },

  toggle : function() {
    if (this.flags.open) {
      this.close();
    } else {
      this.open();
    }
  },
  
  findSelectors : function() {
    this.$s = {
      guide : $('#edit_reorder_pages_guide'),
      guideButton: $('.edit_reorder_pages'),
      page : $('.DV-page,.DV-thumbnail'),
      thumbnails : $('.DV-thumbnails'),
      pages : $('.DV-pages'),
      viewerContainer : $('.DV-docViewer-Container'),
      header : $('#reorder_pages_container'),
      container : null,
      saveButton : $('.reorder_pages_confirm_input')
    };
    
    this.viewer = DV.viewers[_.first(_.keys(DV.viewers))];
    this.imageUrl = this.viewer.schema.document.resources.page.image;
  },
  
  open : function() {
    this.findSelectors();
    this.$s.guideButton.addClass('loading');
    $.getScript('http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.5/jquery-ui.min.js', 
                _.bind(this.postOpen, this));
  },
  
  postOpen : function() {
    this.$s.guideButton.removeClass('loading');
    this.flags.open = true;
    this.viewer.api.enterReorderPagesMode();
    this.viewer.api.resetReorderedPages();
    this.render();
    this.$s.guide.fadeIn('fast');
    this.$s.guideButton.addClass('open');
    this.$s.saveButton.attr('disabled', true);
    this.$s.header.removeClass('active');
  },
  
  render : function() {
    $(this.el).html(JST['viewer/reorder_pages']({}));
    this.$s.viewerContainer.append(this.el);
    this.findSelectors();
    if (this.viewer.state != 'ViewThumbnails') {
        this.viewer.open('ViewThumbnails');
    }
    this.$s.pages.addClass('reorder_pages_viewer');
    this.$s.container = $(this.el);
    _.defer(_.bind(this.setCallbacks, this));
    $('.DV-currentPage', this.$s.thumbnails).removeClass('DV-currentPage')
                                            .addClass('DV-currentPage-disabled');
  },
  
  setCallbacks : function(callbacks) {
    var self = this;
    var $thumbnails = this.$s.thumbnails;
    
    this.findThumbnailsInterval = setInterval(function() {
      if ($('.DV-thumbnail', $thumbnails).length) {
        clearInterval(self.findThumbnailsInterval);
        $('.DV-thumbnail', $thumbnails).each(function(i) {
          $(this).data('pageNumber', i+1);
        });
        $('.DV-currentPage', $thumbnails).removeClass('DV-currentPage').addClass('DV-currentPage-disabled');
        jQuery('.DV-thumbnails').sortable({
          containment: '.DV-thumbnails',
          cursor: 'move',
          scrollSensitivity: 80,
          scrollSpeed: 15,
          tolerance: 'pointer',
          zIndex: 1,
          stop: function(e, ui) {
            self.$s.saveButton.removeAttr('disabled');
            self.$s.header.addClass('active');
          }
        });
      }
    }, 250);
    this.base(callbacks);
  },
  
  confirmReorderPages : function() {
    dc.ui.Dialog.confirm('Reordering pages takes a few minutes to complete.<br /><br />Are you sure you want to continue?', _.bind(function() {
      $('input.reorder_pages_confirm_input', this.el).val('Reordering...').attr('disabled', true);
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
    $('.DV-currentPage-disabled', this.$s.page).addClass('DV-currentPage').removeClass('DV-currentPage-disabled');
    this.flags.open = false;
    jQuery('.DV-thumbnails').sortable('destroy');
    this.$s.guide.fadeOut('fast');
    this.$s.guideButton.removeClass('open');
    this.$s.pages.removeClass('reorder_pages_viewer');
    $(this.el).remove();
    this.viewer.api.leaveReorderPagesMode();
    this.base();
  }

});