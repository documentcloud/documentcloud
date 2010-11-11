dc.ui.ReplacePagesEditor = dc.ui.EditorToolbar.extend({

  id : 'replace_pages_container',

  findSelectors : function() {
    this.$s = {
      guide: $('#edit_replace_pages_guide'),
      guideButton: $('.edit_replace_pages'),
      thumbnails : $('.DV-thumbnail'),
      pages : $('.DV-pages'),
      viewerContainer : $('.DV-docViewer-Container'),
      hint : $(".replace_pages_hint", this.el),
      container : null
    };
  },

  open : function() {
    this.findSelectors();
    this.setMode('is', 'open');
    this.$s.guide.fadeIn('fast');
    this.$s.guideButton.addClass('open');
    this.viewer.api.enterReplacePagesMode();
    this.render();
    this.resetSelected();
  },

  resetSelected : function() {
    $('.DV-currentPageImage', this.$s.pages).removeClass('DV-currentPageImage').addClass('DV-currentPageImage-disabled');
    this.$s.thumbnails.removeClass('DV-selected');
    this.$s.thumbnails.find('.left_chosen,.right_chosen').removeClass('left_chosen')
                                                         .removeClass('right_chosen');
  },

  render : function() {
    $(this.el).html(JST['replace_pages']({}));
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
      autoStart   : true,
      documentId  : this.viewer.api.getModelId()
    });
    dc.app.uploader.setupUploadify();

    this.handleEvents();
    this.delegateEvents();
  },

  unbindEvents : function() {
    var $thumbnails = this.$s.thumbnails;
    $thumbnails.unbind('mouseout.dv-replace')
               .unbind('mousemove.dv-replace')
               .unbind('mousedown.dv-replace')
               .unbind('mouseover.dv-replace')
               .unbind('mouseenter.dv-replace')
               .unbind('mouseleave.dv-replace');
  },

  handleEvents : function() {
    var $thumbnails = this.$s.thumbnails;

    this.unbindEvents();

    $thumbnails.each(function(i) {
      $(this).data('pageNumber', i+1);
    });

    $thumbnails.bind('mouseout.dv-replace', function() {
      $('.DV-overlay', this).removeClass('left').removeClass('right');
    });
    $thumbnails.bind('mousemove.dv-replace', function(e) {
      var $this = $(this);
      var pageNumber = $this.data('pageNumber');
      var offset = $this.offset();
      var width = $this.outerWidth(true);
      var positionX = e.clientX - offset.left;
      var amount = positionX / width;
      var side = amount < 0.2 ? 'left' : amount > 0.8 ? 'right' : '';
      $('.DV-overlay', $this).removeClass('left').removeClass('right').addClass(side);
    });

    $thumbnails.bind('mousedown.dv-replace', _.bind(function(e) {
      e.preventDefault();
      e.stopPropagation();
      this.confirmPageChoice($(e.currentTarget));
    }, this));
  },

  confirmPageChoice : function($thumbnail) {
    var $thumbnails = this.$s.thumbnails;

    this.resetSelected();

    if (dc.app.hotkeys.shift && this.$firstPageSelection) {
      var firstPageNumber = this.$firstPageSelection.data('pageNumber');
      var thumbnailPageNumber = $thumbnail.data('pageNumber');
      var end = Math.max(thumbnailPageNumber, firstPageNumber);
      var start = Math.min(thumbnailPageNumber, firstPageNumber);
      var isReverse = firstPageNumber > thumbnailPageNumber;

      if (!$thumbnail.hasClass('DV-hover-image')) {
        if ($('.left', $thumbnail).length && !isReverse) {
          end -= 1;
        } else if ($('.right', $thumbnail).length && isReverse) {
          start += 1;
        }
      }

      $thumbnails = $thumbnails.filter(function() {
        var page = $(this).data('pageNumber');
        return start <= page && page <= end;
      });
      $thumbnails.addClass('DV-selected');
      this.updateHint('replace');
    } else {
      if ($thumbnail.hasClass('DV-hover-image')) {
        this.$firstPageSelection = $thumbnail;
        $thumbnail.addClass('DV-selected');
        this.updateHint('replace');
      } else if ($thumbnail.hasClass('DV-hover-thumbnail')) {
        var $left = $('.left', $thumbnails);
        var $right = $('.right', $thumbnails);

        if ($left.length) {
          $left.addClass('left_chosen');
          this.$firstPageSelection = $thumbnail;
        } else if ($right.length) {
          $right.addClass('right_chosen');
          this.$firstPageSelection = $thumbnail.next();
        }
        this.updateHint('insert');
      }
    }
  },

  updateHint : function(state) {
    var hint;

    if (state == 'choose') {
      hint = "Choose which pages to replace.";
      $(this.el).setMode('off', 'upload');
    } else if (state == 'replace') {
      var range = this.getPageRange();
      $(this.el).setMode('on', 'upload');
      hint = "Upload documents to replace ";
      if (range.start != range.end) {
        hint += "pages " + range.start + " through " + range.end + ".";
      } else {
        hint += "page " + range.start + ".";
      }
      this.updateUploader({
        insertPageAt: null,
        replacePagesStart: range.start,
        replacePagesEnd: range.end
      });
    } else if (state == 'insert') {
      var pageCount = this.viewer.api.numberOfPages();
      var pageNumber = this.getInsertPageNumber();
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
        insertPageAt: pageNumber,
        replacePagesStart: null,
        replacePagesEnd: null
      });
    }

    this.$s.hint.text(hint);
  },

  updateUploader : function(attrs) {
    dc.app.uploader.insertPagesAttrs(attrs);
  },

  getPageRange : function() {
    var $thumbnails = this.$s.thumbnails;
    var $thumbnail = $thumbnails.filter('.DV-selected');

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

  getInsertPageNumber : function() {
    var $active = this.$s.thumbnails.has('.left,.right');
    var pageNumber = $active.data('pageNumber');

    if ($active.find('.left').length) {
      return pageNumber - 1;
    } else if ($active.find('.right').length) {
      return pageNumber;
    }
  },

  close : function() {
    if (this.modes.open == 'is') {
      $('.DV-currentPageImage-disabled', this.$s.pages).addClass('DV-currentPageImage').removeClass('DV-currentPageImage-disabled');
      $('.left_chosen').removeClass('left_chosen');
      $('.right_chosen').removeClass('right_chosen');
      this.setMode('not', 'open');
      this.$s.guide.hide();
      this.unbindEvents();
      this.$s.guideButton.removeClass('open');
      this.$s.pages.removeClass('replace_pages_viewer');
      $(this.el).remove();
      this.viewer.api.leaveReplacePagesMode();
    }
  }

});