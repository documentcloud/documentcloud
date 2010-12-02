dc.ui.ReplacePagesEditor = dc.ui.EditorToolbar.extend({

  id : 'replace_pages_container',

  findSelectors : function() {
    this.$s = {
      guide: $('#edit_replace_pages_guide'),
      guideButton: $('.edit_replace_pages'),
      thumbnails : $('.DV-thumbnail'),
      thumbnailImages : $('.DV-thumbnail .DV-thumbnail-image'),
      pages : $('.DV-pages'),
      viewerContainer : $('.DV-docViewer-Container'),
      hint : this.$(".editor_hint"),
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
    var $thumbnailImages = this.$s.thumbnailImages;
    $thumbnails.unbind('mouseout.dv-replace')
               .unbind('mousemove.dv-replace')
               .unbind('mousedown.dv-replace')
               .unbind('mouseover.dv-replace')
               .unbind('mouseenter.dv-replace')
               .unbind('mouseleave.dv-replace');
    $thumbnailImages.unbind('mouseout.dv-replace')
                    .unbind('mouseover.dv-replace');
  },

  handleEvents : function() {
    var $thumbnails = this.$s.thumbnails;
    var $thumbnailImages = this.$s.thumbnailImages;

    this.unbindEvents();

    $thumbnails.each(function(i) {
      $(this).attr('data-pageNumber', i+1);
    });

    $thumbnails.bind('mouseover.dv-replace', function() {
      $(this).addClass('DV-hover-thumbnail');
    });
    $thumbnails.bind('mouseout.dv-replace', function() {
      $('.DV-overlay', this).removeClass('left').removeClass('right');
      $(this).removeClass('DV-hover-thumbnail');
    });
    $thumbnails.bind('mousemove.dv-replace', function(e) {
      var $this = $(this);
      if (!$this.hasClass('DV-hover-image')) {
        var pageNumber = $this.attr('data-pageNumber');
        var offset = $this.offset();
        var width = $this.outerWidth(true);
        var positionX = e.clientX - offset.left;
        var amount = positionX / width;
        var side = amount < 0.2 ? 'left' : amount > 0.8 ? 'right' : '';
        $('.DV-overlay', $this).removeClass('left').removeClass('right').addClass(side);
      }
    });

    $thumbnails.bind('mousedown.dv-replace', _.bind(function(e) {
      e.preventDefault();
      e.stopPropagation();
      this.confirmPageChoice($(e.currentTarget));
    }, this));

    $thumbnailImages.bind('mouseover.dv-replace', function(e) {
        $(this).closest('.DV-thumbnail').addClass('DV-hover-image');
    });

    $thumbnailImages.bind('mouseout.dv-replace', function(e) {
        $(this).closest('.DV-thumbnail').removeClass('DV-hover-image');
    });
  },

  confirmPageChoice : function($thumbnail) {
    var $thumbnails = this.$s.thumbnails;
    var isSingleSelection = true;

    this.resetSelected();

    if (dc.app.hotkeys.shift && this.$firstPageSelection && this.$firstPageSelection.length) {
      var firstPageNumber = parseInt(this.$firstPageSelection.attr('data-pageNumber'), 10);
      var thumbnailPageNumber = parseInt($thumbnail.attr('data-pageNumber'), 10);
      var end = Math.max(thumbnailPageNumber, firstPageNumber);
      var start = Math.min(thumbnailPageNumber, firstPageNumber);
      var isReverse = firstPageNumber > thumbnailPageNumber;
      var isLeft = $('.DV-overlay', $thumbnail).hasClass('left');
      var isRight = $('.DV-overlay', $thumbnail).hasClass('right');

      isSingleSelection = false;

      if (!$thumbnail.hasClass('DV-hover-image')) {
        if (isLeft && isReverse) {
          end -= 1;
        } else if (isLeft && !isReverse) {
          end -= 1;
        } else if (isRight && isReverse) {
          start += 1;
          end -= 1;
        }
      }
      if (!isLeft && !isRight && isReverse) {
        end -= 1;
      }
      if (isReverse && !this.isFirstPageBetween) {
        end += 1;
      }
      if (end < start) isSingleSelection = true;
      console.log(['confirm', firstPageNumber, thumbnailPageNumber, start, end, isReverse, isLeft, isRight]);

      if (!isSingleSelection) {
        $thumbnails = $thumbnails.filter(function() {
          var page = $(this).attr('data-pageNumber');
          return start <= page && page <= end;
        });
        $thumbnails.addClass('DV-selected');
        this.updateHint('replace');
      }
    }
    if (isSingleSelection) {
      if ($thumbnail.hasClass('DV-hover-image')) {
        this.$firstPageSelection = $thumbnail;
        this.isFirstPageBetween = false;
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
          if (!this.$firstPageSelection.length) this.$firstPageSelection = $thumbnail;
        }
        this.isFirstPageBetween = true;
        this.updateHint('insert');
      }
    }
  },

  updateHint : function(state) {
    var hint, range, insertion;

    if (state == 'choose') {
      hint = "Choose a location to insert pages.";
      $(this.el).setMode('off', 'upload');
    } else {
      var replace = state == 'replace';
      $(this.el).setMode('on', 'upload');
      hint = replace ? 'Replace ' : 'Insert ';
      if (replace) {
        range = this.getPageRange();
        if (range.start != range.end) {
          hint += "pages " + range.start + " through " + range.end + ".";
        } else {
          hint += "page " + range.start + ".";
        }
      } else if (state == 'insert') {
        var pageCount = this.viewer.api.numberOfPages();
        var insertion = this.getInsertPageNumber();
        if (insertion < 1) {
          hint += "before the first page.";
        } else if (insertion < pageCount) {
          hint += "between pages " + insertion + " and " + (insertion + 1) + ".";
        } else if (insertion >= pageCount) {
          hint += "after the last page.";
        }
      }
      dc.app.uploader.insertPagesAttrs({
        insertPageAt:       insertion,
        replacePagesStart:  range && range.start,
        replacePagesEnd:    range && range.end
      });
    }

    this.$s.hint.text(hint);
  },

  getPageRange : function() {
    var $thumbnails = this.$s.thumbnails;
    var $thumbnail = $thumbnails.filter('.DV-selected');

    var range = _.map($thumbnail, function(t) {
      return parseInt($(t).attr('data-pageNumber'), 10);
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
    var pageNumber = parseInt($active.attr('data-pageNumber'), 10);

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
      $('.DV-selected').removeClass('DV-selected');
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