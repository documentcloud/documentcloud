dc.ui.ReorderPagesEditor = Backbone.View.extend({

  id : 'reorder_pages_container',
  className : 'editing_toolbar interface',

  flags : {
    open: false
  },

  events : {
    'click .reorder_pages_confirm_input' : 'confirmReorderPages'
  },

  constructor : function(opts) {
    Backbone.View.call(this, opts);
    _.bindAll(this, 'confirmReorderPages', 'postOpen');
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
    $('.DV-currentPageImage', this.$s.thumbnails).removeClass('DV-currentPageImage')
                                            .addClass('DV-currentPageImage-disabled');
    this.handleEvents();
    this.initialOrder = this.serializePageOrder();
  },

  handleEvents : function() {
    var $thumbnails = this.$s.thumbnails;

    $('.DV-thumbnail', $thumbnails).each(function(i) {
      $(this).data('pageNumber', i+1);
    });
    $('.DV-currentPageImage', $thumbnails).removeClass('DV-currentPageImage').addClass('DV-currentPageImage-disabled');
    jQuery('.DV-thumbnails').sortable({
      containment: '.DV-thumbnails',
      cursor: 'move',
      scrollSensitivity: 80,
      scrollSpeed: 15,
      tolerance: 'pointer',
      zIndex: 1,
      stop: _.bind(function(e, ui) {
        this.refreshHeader();
      }, this)
    });
  },

  refreshHeader : function() {
    var order = this.serializePageOrder();

    if (_.isEqual(order, this.initialOrder)) {
      this.$s.saveButton.attr('disabled', true);
      this.$s.header.removeClass('active');
    } else {
      this.$s.saveButton.removeAttr('disabled');
      this.$s.header.addClass('active');
    }
  },

  confirmReorderPages : function() {
    dc.ui.Dialog.confirm('Reordering pages takes a few minutes to complete.<br /><br />Are you sure you want to continue?', _.bind(function() {
      $('input.reorder_pages_confirm_input', this.el).val('Reordering...').attr('disabled', true);
      this.save();
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

  save : function() {
    var pageOrder = this.serializePageOrder();
    var modelId = this.viewer.api.getModelId();

    $.ajax({
      url       : '/documents/' + modelId + '/reorder_pages',
      type      : 'POST',
      data      : { page_order : pageOrder },
      dataType  : 'json',
      success   : function(resp) {
        window.opener && window.opener.Documents && window.opener.Documents.get(modelId).set(resp);
        dc.ui.Dialog.alert('This process will take a few minutes.<br /><br />This window must close while pages are being reordered and the document is being reconstructed.', {
          onClose : function() {
            window.close();
          }
        });
      }
    });
  },

  close : function() {
    if (this.flags.open) {
      $('.DV-currentPageImage-disabled', this.$s.page).addClass('DV-currentPageImage').removeClass('DV-currentPageImage-disabled');
      this.flags.open = false;
      jQuery('.DV-thumbnails').sortable('destroy');
      this.$s.guide.fadeOut('fast');
      this.$s.guideButton.removeClass('open');
      this.$s.pages.removeClass('reorder_pages_viewer');
      $(this.el).remove();
      this.viewer.api.leaveReorderPagesMode();
    }
  }

});