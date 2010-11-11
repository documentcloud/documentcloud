dc.ui.RemovePagesEditor = Backbone.View.extend({

  id : 'remove_pages_container',
  className : 'editing_toolbar interface',

  flags : {
    open: false
  },

  events : {
    'click .document_page_tile_remove'  : 'removePageFromRemoveSet',
    'click .remove_pages_confirm_input' : 'confirmRemovePages'
  },

  constructor : function(opts) {
    Backbone.View.call(this, opts);
    _.bindAll(this, 'confirmRemovePages', 'removePageFromRemoveSet');
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
      guide : $('#edit_remove_pages_guide'),
      guideButton: $('.edit_remove_pages'),
      thumbnails : $('.DV-thumbnail'),
      pages : $('.DV-pages'),
      viewerContainer : $('.DV-docViewer-Container'),
      holder : null,
      container : null
    };

    this.viewer = DV.viewers[_.first(_.keys(DV.viewers))];
    this.imageUrl = this.viewer.schema.document.resources.page.image;
  },

  open : function() {
    this.findSelectors();
    this.removePages = [];
    this.flags.open = true;
    this.$s.guide.fadeIn('fast');
    this.$s.guideButton.addClass('open');
    this.viewer.api.enterRemovePagesMode();
    this.render();
  },

  render : function() {
    $(this.el).show().html(JST['viewer/remove_pages']({}));
    this.$s.viewerContainer.append(this.el);
    if (this.viewer.state != 'ViewDocument' && this.viewer.state != 'ViewThumbnails') {
        this.viewer.open('ViewThumbnails');
    }
    this.$s.pages.addClass('remove_pages_viewer');
    this.$s.thumbnails.removeClass('DV-selected');
    this.$s.holder = $('.remove_pages_holder', this.el);
    this.$s.container = $(this.el);
    this.redrawPages();
    this.handleEvents();
  },

  unbindEvents : function() {
    var $thumbnails = this.$s.thumbnails;
    $thumbnails.unbind('mousedown.dv-remove');
  },

  handleEvents : function() {
    var $thumbnails = this.$s.thumbnails;

    this.unbindEvents();

    $thumbnails.each(function(i) {
      $(this).data('pageNumber', i+1);
    });

    $thumbnails.bind('mousedown.dv-remove', _.bind(function(e) {
      var $thumbnail = $(e.currentTarget);
      var imageSrc = $('.DV-pageImage,.DV-thumbnail-image img', $thumbnail).eq(0).attr('src');
      var pageNumber = $thumbnail.data('pageNumber');
      if (_.contains(this.removePages, pageNumber)) {
        this.removePageNumberFromRemoveSet(pageNumber);
      } else {
        this.addPageToRemoveSet(pageNumber);
      }
    }, this));
  },

  addPageToRemoveSet : function(pageNumber) {
    if (!(_.contains(this.removePages, pageNumber))) {
      this.viewer.api.addPageToRemovedPages(pageNumber);
      this.removePages.push(pageNumber);
      this.redrawPages();
      this.$s.thumbnails.eq(pageNumber-1).addClass('DV-selected');
    }
  },

  removePageFromRemoveSet : function(e) {
    var pageNumber = $(e.target).parents('.document_page_tile').data('pageNumber');
    this.removePageNumberFromRemoveSet(pageNumber);
  },

  removePageNumberFromRemoveSet : function(pageNumber) {
    this.removePages = _.reject(this.removePages, function(p) { return p == pageNumber; });
    this.redrawPages();
    this.viewer.api.removePageFromRemovedPages(pageNumber);
    this.$s.thumbnails.eq(pageNumber-1).removeClass('DV-selected');
  },

  redrawPages : function() {
    var pageCount = this.removePages.length;
    this.removePages = this.removePages.sort(function(a, b) { return a - b; });
    $('.document_page_tile', this.$s.holder).empty().remove();

    if (pageCount == 0) {
      this.$s.container.addClass('empty');
    } else {
      this.$s.container.removeClass('empty');
    }

    // Create each page tile and add it to the page holder
    _.each(this.removePages, _.bind(function(pageNumber) {
      var url = this.imageUrl;
      url = url.replace(/\{size\}/, 'thumbnail');
      url = url.replace(/\{page\}/, pageNumber);
      var $thumbnail = $(JST['viewer/document_page_tile']({
        url : url,
        pageNumber : pageNumber
      }));
      $thumbnail.data('pageNumber', pageNumber);
      this.$s.holder.append($thumbnail);
    }, this));

    // Update remove button's text
    var removeText = 'Remove ' + pageCount + Inflector.pluralize(' page', pageCount);
    $('.remove_pages_confirm_button input[type=button]', this.el).val(removeText);

    // Set width of container for side-scrolling
    var width = $('.document_page_tile').length * $('.document_page_tile').eq(0).outerWidth(true);
    var confirmWidth = $('.remove_pages_confirm', this.el).outerWidth(true);
    this.$s.holder.width(width + confirmWidth);
  },

  confirmRemovePages : function() {
    var pageCount = this.removePages.length;
    dc.ui.Dialog.confirm('Removing pages takes a few minutes to complete.<br /><br />Are you sure you want to remove ' + pageCount + Inflector.pluralize(' page', pageCount) + '?', _.bind(function() {
      $('input.remove_pages_confirm_input', this.el).val('Removing...').attr('disabled', true);
      this.save();
      return true;
    }, this));
  },

  save : function() {
    var modelId = this.viewer.api.getModelId();

    $.ajax({
      url       : '/documents/' + modelId + '/remove_pages',
      type      : 'POST',
      data      : { pages : this.removePages },
      dataType  : 'json',
      success   : function(resp) {
        window.opener && window.opener.Documents && window.opener.Documents.get(modelId).set(resp);
        dc.ui.Dialog.alert('This process will take a few minutes.<br /><br />This window must close while pages are being removed and the document is being reconstructed.', {
          onClose : function() {
            window.close();
          }
        });
      }
    });
  },

  close : function() {
    if (this.flags.open) {
      this.flags.open = false;
      this.$s.guide.fadeOut('fast');
      this.$s.guideButton.removeClass('open');
      this.$s.pages.removeClass('remove_pages_viewer');
      this.unbindEvents();
      $(this.el).empty().hide().remove();
      this.viewer.api.leaveRemovePagesMode();
    }
  }

});