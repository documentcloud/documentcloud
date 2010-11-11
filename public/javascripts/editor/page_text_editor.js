dc.ui.PageTextEditor = dc.ui.EditorToolbar.extend({

  id : 'edit_page_text_container',

  events : {
    'click .edit_page_text_confirm_input' : 'confirmEditPageText',
    'click .document_page_tile_remove'    : 'resetPage'
  },

  originalPageText: {},
  pageText: {},

  initialize : function(opts) {
    _.bindAll(this, 'confirmEditPageText', 'cachePageText', 'resetPage');
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
      saveButton : $('.edit_page_text_confirm_input', this.el),
      headerTiles : $('.document_page_tiles', this.el)
    };
  },

  open : function() {
    this.findSelectors();
    this.originalPageText = {};
    this.pageText = {};
    this.setMode('is', 'open');
    this.render();
    this.viewer.api.enterEditPageTextMode();
  },

  render : function() {
    $(this.el).html(JST['edit_page_text']({}));
    this.$s.viewerContainer.append(this.el);
    if (this.viewer.state != 'ViewText') {
        this.viewer.open('ViewText');
    }
    this.$s.pages.addClass('edit_page_text_viewer');
    this.$s.container = $(this.el);
    this.findSelectors();
    this.$s.guideButton.addClass('open');
    this.$s.guide.fadeIn('fast');
    this.$s.saveButton.setMode('not', 'enabled');
    this.$s.header.removeClass('active');
    this.$s.textContents.attr('contentEditable', true);
    this.$s.textContents.addClass('DV-editing');

    this.handleEvents();
  },

  handleEvents : function() {
    this.$s.textContents.bind('keyup', this.cachePageText);
    this.$s.textContents.bind('change', this.cachePageText);
  },

  getPageNumber : function() {
    return this.viewer.api.currentPage();
  },

  getPageText : function(pageNumber) {
    pageNumber = pageNumber || this.getPageNumber();

    return this.viewer.api.getPageText(pageNumber);
  },

  confirmEditPageText : function() {
    var modifiedPages = this.getChangedPageTextPages();
    var documentId = this.viewer.api.getModelId();

    $('input.edit_page_text_confirm_input', this.el).val('Saving...').setMode('not', 'enabled');

    $.ajax({
      url       : '/documents/' + documentId + '/save_page_text',
      type      : 'POST',
      data      : { modified_pages : JSON.stringify(modifiedPages) },
      dataType  : 'json',
      success   : _.bind(function(resp) {
        this.viewer.api.resetPageText(true);
        this.close();
      }, this)
    });
  },

  cachePageText : function() {
    var pageNumber = this.getPageNumber();
    var pageText = Inflector.trim(this.extractText(this.$s.textContents));

    if (!(pageNumber in this.originalPageText)) {
      this.originalPageText[pageNumber] = $.trim(this.getPageText(pageNumber));
    }

    if (pageText != this.originalPageText[pageNumber]) {
      this.pageText[pageNumber] = pageText;
    } else {
      delete this.originalPageText[pageNumber];
      delete this.pageText[pageNumber];
    }

    this.viewer.api.setPageText(pageText, pageNumber);
    this.redrawHeader();
  },

  resetPage : function(e) {
    var pageNumber = $(e.currentTarget).parents('.document_page_tile').data('pageNumber');

    this.viewer.api.setPageText(this.originalPageText[pageNumber], pageNumber);
    this.viewer.api.enterEditPageTextMode();
    delete this.originalPageText[pageNumber];
    delete this.pageText[pageNumber];
    this.redrawHeader();
  },

  redrawHeader : function() {
    var saveText;
    var editedPages = _.keys(this.originalPageText);
    var pageCount = editedPages.length;
    editedPages = editedPages.sort(function(a, b) { return a - b; });
    $('.document_page_tile', this.$s.headerTiles).empty().remove();

    if (pageCount == 0) {
      this.$s.header.removeClass('active');
      this.$s.saveButton.setMode('not', 'enabled');
    } else {
      this.$s.header.addClass('active');
      this.$s.saveButton.setMode('is', 'enabled');
    }

    // Create each page tile and add it to the page holder
    _.each(editedPages, _.bind(function(pageNumber) {
      var url = this.imageUrl;
      url = url.replace(/\{size\}/, 'thumbnail');
      url = url.replace(/\{page\}/, pageNumber);
      var $thumbnail = $(JST['document_page_tile']({
        url : url,
        pageNumber : pageNumber
      }));
      $thumbnail.data('pageNumber', pageNumber);
      this.$s.headerTiles.append($thumbnail);
    }, this));

    // Update remove button's text
    if (pageCount == 0) {
      saveText = 'Save page text';
    } else {
      saveText = 'Save ' + pageCount + Inflector.pluralize(' page', pageCount);
    }
    $('.edit_page_text_confirm_input', this.el).val(saveText);

    // Set width of container for side-scrolling
    var width = $('.document_page_tile').length * $('.document_page_tile').eq(0).outerWidth(true);
    var confirmWidth = $('.remove_pages_confirm', this.el).outerWidth(true);
    this.$s.headerTiles.width(width + confirmWidth);
    Backbone.View.prototype.delegateEvents.call(this);
  },

  extractText : function(elems) {
    var ret = "", elem;

    _.each(elems, _.bind(function(elem) {
      if (elem.nodeType == 3 || elem.nodeType == 4) {
        // Get the text from text nodes and CDATA nodes
        ret += elem.nodeValue;
      } else if (elem.nodeType != 8) {
        // Traverse everything else, except comment nodes
        ret += this.extractText(elem.childNodes) + '\n';
      }
    }, this));

    return ret;
  },

  getChangedPageTextPages : function() {
    var modifiedPages = {};
    _.each(this.pageText, _.bind(function(pageText, pageNumber) {
      if (this.originalPageText[pageNumber] != pageText) {
        modifiedPages[pageNumber] = pageText;
      }
    }, this));

    return modifiedPages;
  },

  close : function() {
    if (this.modes.open == 'is') {
      this.setMode('not', 'open');
      this.$s.guideButton.removeClass('open');
      this.$s.guide.fadeOut('fast');
      this.$s.pages.removeClass('edit_page_text_viewer');
      this.$s.textContents.attr('contentEditable', false);
      this.$s.textContents.removeClass('DV-editing');
      $(this.el).remove();
      this.viewer.api.leaveEditPageTextMode();
    }
  }

});