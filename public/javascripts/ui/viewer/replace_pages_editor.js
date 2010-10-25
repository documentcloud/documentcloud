dc.ui.ReplacePagesEditor = Backbone.View.extend({
  
  id : 'replace_pages_container',
  
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
      guideButton: $('.edit_replace_pages'),
      thumbnails : $('.DV-thumbnail'),
      pages : $('.DV-pages'),
      viewerContainer : $('.DV-docViewer-Container'),
      hint : $(".replace_pages_hint", this.el),
      container : null
    };
    
    this.viewer = DV.viewers[_.first(_.keys(DV.viewers))];
    this.imageUrl = this.viewer.schema.document.resources.page.image;
  },
  
  open : function() {
    dc.app.hotkeys.initialize();
    this.findSelectors();
    this.flags.open = true;
    this.$s.guideButton.addClass('open');
    this.viewer.api.enterReplacePagesMode();
    this.render();
    this.$s.thumbnails.removeClass('DV-removePage');
    $('.DV-currentPage', this.$s.pages).removeClass('DV-currentPage').addClass('DV-currentPage-disabled');
  },
  
  render : function() {
    $(this.el).html(JST['viewer/replace_pages']({}));
    this.$s.viewerContainer.append(this.el);
    if (this.viewer.state != 'ViewThumbnails') {
        this.viewer.open('ViewThumbnails');
    }
    this.$s.pages.addClass('replace_pages_viewer');
    this.$s.container = $(this.el);
    this.findSelectors();
    this.updateHint('choose');
    dc.app.uploader = new dc.ui.UploadDialog({
      editable    : false,
      insertPages : true,
      documentId  : this.viewer.api.getModelId()
    });
    dc.app.uploader.setupUploadify();
  },
  
  delegateEvents : function(callbacks) {
    var $thumbnails = this.$s.thumbnails;
    
    $thumbnails.each(function(i) {
      $(this).data('pageNumber', i+1);
    });
    $thumbnails.bind('click', _.bind(function(e) {
      e.preventDefault();
      this.confirmPageChoice($(e.currentTarget));
    }, this));
    
    Backbone.View.prototype.delegateEvents.call(this, callbacks);
  },
  
  confirmPageChoice : function($thumbnail) {
    var $thumbnails = this.$s.thumbnails;
    
    $thumbnails.removeClass('DV-removePage');
    if (dc.app.hotkeys.shift && this.$firstPageSelection) {
        var end = Math.max($thumbnail.data('pageNumber'), this.$firstPageSelection.data('pageNumber'));
        var start = Math.min($thumbnail.data('pageNumber'), this.$firstPageSelection.data('pageNumber'));
        $thumbnails = $thumbnails.filter(function() {
          var page = $(this).data('pageNumber');
          return start <= page && page <= end;
        });
        $thumbnails.addClass('DV-removePage');
    } else {
        this.$firstPageSelection = $thumbnail;
        $thumbnail.addClass('DV-removePage');
    }
    
    this.updateHint('upload');
  },

  updateHint : function(state) {
    var range = this.getPageRange();
    var pageCount = this.viewer.api.numberOfPages();
    var hint;

    if (state == 'choose') {
      hint = "Choose which pages to replace.";
      $(this.el).setMode('off', 'upload');
    } else if (state == 'upload') {
      $(this.el).setMode('on', 'upload');
      hint = "Upload documents to replace ";
      if (range.start != range.end) {
        hint += "pages " + range.start + " through " + range.end + ".";
      } else {
        hint += "page " + range.start + ".";
      }
      this.updateUploader({
        replacePagesStart: range.start,
        replacePagesEnd: range.end
      });
    }
    
    this.$s.hint.text(hint);
  },
  
  updateUploader : function(attrs) {
    dc.app.uploader.insertPagesAttrs(attrs);
  },
  
  getPageRange : function() {
    var $thumbnails = this.$s.thumbnails;
    var $thumbnail = $thumbnails.filter('.DV-removePage');
    
    var range = _.map($thumbnail, function(t) {
      return parseInt($(t).data('pageNumber'), 10);
    });
    var start = _.min(range);
    var end = _.max(range);
    
    return {
      start: start,
      end: end
    };
  },
  
  close : function() {
    if (this.flags.open) {
      $('.DV-currentPage-disabled', this.$s.pages).addClass('DV-currentPage').removeClass('DV-currentPage-disabled');
      this.flags.open = false;
      this.$s.guideButton.removeClass('open');
      this.$s.pages.removeClass('replace_pages_viewer');
      $(this.el).remove();
      this.viewer.api.leaveReplacePagesMode();
    }
  }

});