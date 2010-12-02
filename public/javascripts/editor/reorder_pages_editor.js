dc.ui.ReorderPagesEditor = dc.ui.EditorToolbar.extend({

  id : 'reorder_pages_container',

  events : {
    'click .reorder_pages_confirm_input' : 'confirmReorderPages'
  },

  initialize : function(opts) {
    _.bindAll(this, 'confirmReorderPages', 'postOpen');
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
  },

  open : function() {
    this.findSelectors();
    this.setMode('is', 'open');
    this.viewer.api.enterReorderPagesMode();
    this.viewer.api.resetReorderedPages();
    this.render();
    this.orderChanged = false;
    this.$s.guide.fadeIn('fast');
    this.$s.guideButton.addClass('open');
    this.$s.saveButton.setMode('not', 'enabled');
  },

  render : function() {
    $(this.el).html(JST['reorder_pages']({}));
    this.$s.viewerContainer.append(this.el);
    this.findSelectors();
    if (this.viewer.state != 'ViewThumbnails') {
        this.viewer.open('ViewThumbnails');
    }
    this.$s.pages.addClass('reorder_pages_viewer');
    this.$s.container = $(this.el);
    $('.DV-currentPageImage', this.$s.thumbnails).removeClass('DV-currentPageImage')
                                            .addClass('DV-currentPageImage-disabled');
    this.handleEvents();
    this.initialOrder = this.serializePageOrder();
  },

  handleEvents : function() {
    var $thumbnails = this.$s.thumbnails;

    $('.DV-thumbnail', $thumbnails).each(function(i) {
      $(this).attr('data-pageNumber', i+1);
    });
    $('.DV-currentPageImage', $thumbnails).removeClass('DV-currentPageImage').addClass('DV-currentPageImage-disabled');
    jQuery('.DV-thumbnails').sortable({
      containment: '.DV-thumbnails',
      items: '.DV-thumbnail',
      handle: '.DV-thumbnail-page',
      cursor: 'move',
      scrollSensitivity: 80,
      scrollSpeed: 15,
      tolerance: 'pointer',
      zIndex: 10,
      stop: _.bind(function(e, ui) {
        this.refreshHeader();
      }, this)
    });
  },

  refreshHeader : function() {
    var order = this.serializePageOrder();

    if (_.isEqual(order, this.initialOrder)) {
      this.orderChanged = false;
      this.$s.saveButton.setMode('not', 'enabled');
    } else {
      this.orderChanged = true;
      this.$s.saveButton.setMode('is', 'enabled');
    }
  },

  confirmReorderPages : function() {
    if (!this.orderChanged) return;
    dc.ui.Dialog.confirm('This window will be closed while the document is reordered. Are you sure you want to proceed?', _.bind(function() {
      $('input.reorder_pages_confirm_input', this.el).val('Reordering...').attr('disabled', true);
      this.save();
      return true;
    }, this));
  },

  serializePageOrder : function() {
    var pageOrder = [];

    $('.DV-thumbnail', this.$s.thumbnails).each(function() {
      pageOrder.push(parseInt($(this).attr('data-pageNumber'), 10));
    });

    return pageOrder;
  },

  save : function() {
    dc.ui.Dialog.progress("Reordering Pages&hellip;");
    var pageOrder = this.serializePageOrder();
    var modelId = this.viewer.api.getModelId();

    $.ajax({
      url       : '/documents/' + modelId + '/reorder_pages',
      type      : 'POST',
      data      : { page_order : pageOrder },
      dataType  : 'json',
      success   : function(resp) {
        try {
          window.opener && window.opener.Documents && window.opener.Documents.get(modelId).set(resp);
        } catch (e) {
          // It's alright.
        }
        window.close();
      }
    });
  },

  close : function() {
    if (this.modes.open == 'is') {
      $('.DV-currentPageImage-disabled', this.$s.page).addClass('DV-currentPageImage').removeClass('DV-currentPageImage-disabled');
      this.setMode('not', 'open');
      jQuery('.DV-thumbnails').sortable('destroy');
      this.$s.guide.fadeOut('fast');
      this.$s.guideButton.removeClass('open');
      this.$s.pages.removeClass('reorder_pages_viewer');
      $(this.el).remove();
      this.viewer.api.leaveReorderPagesMode();
    }
  }

});