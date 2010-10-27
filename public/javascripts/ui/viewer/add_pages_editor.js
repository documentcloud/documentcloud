dc.ui.AddPagesEditor = Backbone.View.extend({

  id : 'add_pages_container',

  flags : {
    open: false
  },

  constructor : function(options) {
    Backbone.View.call(this, options);
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
      guideButton     : $('.edit_add_pages'),
      thumbnails      : $('.DV-thumbnail'),
      pages           : $('.DV-pages'),
      viewerContainer : $('.DV-docViewer-Container'),
      hint            : $(".add_pages_hint", this.el),
      container       : null
    };

    this.viewer = DV.viewers[_.first(_.keys(DV.viewers))];
    this.imageUrl = this.viewer.schema.document.resources.page.image;
  },

  open : function() {
    this.findSelectors();
    this.flags.open = true;
    this.$s.guideButton.addClass('open');
    this.viewer.api.enterAddPagesMode();
    this.render();
    this.$s.thumbnails.removeClass('DV-removePage');
    $('.DV-currentPageImage', this.$s.pages).removeClass('DV-currentPageImage').addClass('DV-currentPageImage-disabled');
  },

  render : function() {
    $(this.el).html(JST['viewer/add_pages']({}));
    this.$s.viewerContainer.append(this.el);
    this.updateHint('choose');
    if (this.viewer.state != 'ViewThumbnails') {
        this.viewer.open('ViewThumbnails');
    }
    this.$s.pages.addClass('add_pages_viewer');
    this.$s.container = $(this.el);
    this.findSelectors();
    dc.app.uploader = new dc.ui.UploadDialog({
      editable    : false,
      insertPages : true,
      documentId  : this.viewer.api.getModelId()
    });
    dc.app.uploader.setupUploadify();

    this.handleEvents();
  },

  handleEvents : function() {
    var $thumbnails = this.$s.thumbnails;

    $thumbnails.each(function(i) {
      $(this).data('pageNumber', i+1);
    });
    $thumbnails.mouseout(function() {
      $('.DV-overlay', this).removeClass('left').removeClass('right');
    });
    $thumbnails.mousemove(function(e) {
      var $this = $(this);
      var pageNumber = $this.data('pageNumber');
      var offset = $this.offset();
      var width = $this.outerWidth(true);
      var positionX = e.clientX - offset.left;
      var side = positionX/width < .5 ? 'left' : 'right';
      $('.DV-overlay', $this).removeClass('left').removeClass('right').addClass(side);
    });
    this.$s.pages.bind('click', _.bind(function() {
      this.confirmPageChoice();
    }, this));
  },

  confirmPageChoice : function() {
    this.$s.thumbnails.find('.left_chosen,.right_chosen').removeClass('left_chosen')
                                                         .removeClass('right_chosen');
    $('.left', this.$s.thumbnails).addClass('left_chosen');
    $('.right', this.$s.thumbnails).addClass('right_chosen');

    this.updateHint('upload');
  },

  updateHint : function(state) {
    var pageNumber = this.getPageNumber();
    var pageCount = this.viewer.api.numberOfPages();

    if (state == 'choose' || !_.isNumber(pageNumber)) {
      hint = "Choose where to insert new pages.";
      $(this.el).setMode('off', 'upload');
    } else if (state == 'upload') {
      $(this.el).setMode('on', 'upload');
      hint = "Upload documents to insert ";
      if (pageNumber < 1) {
        hint += "before the first page.";
      } else if (pageNumber < pageCount) {
        hint += "between pages " + pageNumber + " and " + (pageNumber + 1) + ".";
      } else if (pageNumber == pageCount) {
        hint += "after the last page.";
      }
      this.updateUploader({
        insertPageAt: pageNumber
      });
    }

    $('.add_pages_hint', this.el).text(hint);
  },

  updateUploader : function(attrs) {
    dc.app.uploader.insertPagesAttrs(attrs);
  },

  getPageNumber : function() {
    var $active = this.$s.thumbnails.has('.left,.right');
    var pageNumber = $active.data('pageNumber');

    if ($active.find('.left').length) {
      return pageNumber - 1;
    } else if ($active.find('.right').length) {
      return pageNumber;
    }
  },

  close : function() {
    if (this.flags.open) {
      $('.DV-currentPageImage-disabled', this.$s.pages).addClass('DV-currentPageImage').removeClass('DV-currentPageImage-disabled');
      this.flags.open = false;
      this.$s.guideButton.removeClass('open');
      this.$s.pages.removeClass('add_pages_viewer');
      $(this.el).remove();
      this.viewer.api.leaveAddPagesMode();
    }
  }

});