// A tile view for previewing a Document in a listing.
dc.ui.Document = Backbone.View.extend({

  // Number of pages to show at a time.
  PAGE_LIMIT : 50,

  // To display if the document failed to upload.
  ERROR_MESSAGE : "<span class=\"interface\">Our system was unable to process \
    this document. We've been notified of the problem and periodially review \
    these errors. Please review our \
    <span class=\"text_link troubleshoot\">troubleshooting suggestions</span> or \
    <span class=\"text_link contact_us\">contact us</span> for immediate assistance.</span>",

  className : 'document',

  events : {
    'mousedown .doc_title'      : '_noSelect',
    'click .doc_title'          : 'select',
    'contextmenu .doc_title'    : 'showMenu',
    'dblclick .doc_title'       : 'viewDocument',
    'click .icon.doc'           : 'select',
    'contextmenu .icon.doc'     : 'showMenu',
    'dblclick .icon.doc'        : 'viewDocument',
    'click .show_notes'         : 'toggleNotes',
    'click .title .edit_glyph'  : 'openDialog',
    'click .title .lock'        : 'editAccessLevel',
    'click .title .published'   : 'viewPublishedDocuments',
    'click .page_icon'          : '_openPage',
    'click .occurrence'         : '_openPage',
    'click .cancel_search'      : '_hidePages',
    'click .page_count'         : '_togglePageImages',
    'click .search_account'     : 'searchAccount',
    'click .search_group'       : 'searchOrganization',
    'click .search_source'      : 'searchSource',
    'click .change_publish_at'  : 'editPublishAt',
    'click .troubleshoot'       : 'openTroubleshooting',
    'click .contact_us'         : 'openContactUs',
    'click .open_pages'         : 'openPagesInViewer',
    'click .page_list .left'    : 'previousPage',
    'click .page_list .right'   : 'nextPage'
  },

  constructor : function(options) {
    Backbone.View.call(this, options);
    this.el.id = 'document_' + this.model.id;
    this._currentPage = 0;
    this._showingPages = false;
    this.setMode(this.model.get('annotation_count') ? 'owns' : 'no', 'notes');
    _.bindAll(this, '_onDocumentChange', '_onDrop', '_addNote', '_renderNotes',
      '_renderPages', '_setSelected', 'viewDocuments', 'viewPublishedDocuments',
      'openDialog', 'openEmbed', 'setAccessLevelAll', 'viewEntities', 'deleteDocuments',
      '_openShareDialog');
    this.model.bind('change', this._onDocumentChange);
    this.model.bind('change:selected', this._setSelected);
    this.model.notes.bind('add', this._addNote);
    this.model.notes.bind('refresh', this._renderNotes);
    this.model.pageEntities.bind('refresh', this._renderPages);
  },

  render : function() {
    var me = this;
    var title = this.model.get('title');
    var data = _.extend(this.model.toJSON(), {
      model         : this.model,
      created_at    : this.model.get('created_at').replace(/\s/g, '&nbsp;'),
      icon          : this._iconAttributes(),
      thumbnail_url : this._thumbnailURL()
    });
    $(this.el).html(JST['document/tile'](data));
    this._displayDescription();
    if (dc.account) this.$('.doc.icon').draggable({ghost : true, onDrop : this._onDrop});
    this.notesEl = this.$('.notes');
    this.pagesEl = this.$('.pages');
    this.model.notes.each(function(note){ me._addNote(note); });
    this.setMode(dc.access.NAMES[this.model.get('access')], 'access');
    this.setMode(this.model.allowedToEdit() ? 'is' : 'not', 'editable');
    this._setSelected();
    return this;
  },

  // Desktop-style selection.
  select : function(e) {
    e.preventDefault();
    if (!this.model.get('selectable')) return;
    var alreadySelected =  this.model.get('selected');
    var hk = dc.app.hotkeys;
    var anchor = Documents.firstSelection || Documents.selected()[0];
    if (hk.command || hk.control) {
      // Toggle.
      this.model.set({selected : !alreadySelected});
    } else if (hk.shift && anchor) {
      // Range.
      var idx = Documents.indexOf(this.model), aidx = Documents.indexOf(anchor);
      var start = Math.min(idx, aidx), end = Math.max(idx, aidx);
      Documents.each(function(doc, index) {
        doc.set({selected : index >= start && index <= end});
      });
    } else {
      // Regular.
      Documents.deselectAll();
      this.model.set({selected : true});
    }
  },

  viewDocument : function(e) {
    this.model.openViewer();
    return false;
  },

  viewPublishedDocuments : function() {
    var docs = Documents.chosen(this.model);
    if (!docs.length) return;
    _.each(docs, function(doc){
      if (doc.isPublished()) doc.openPublishedViewer();
    });
  },

  viewDocuments : function() {
    var docs = Documents.chosen(this.model);
    if (!docs.length) return;
    _.each(docs, function(doc){ doc.openViewer(); });
  },

  viewPDF : function() {
    this.model.openPDF();
  },

  viewFullText : function() {
    this.model.openText();
  },

  viewEntities : function() {
    dc.app.searcher.viewEntities(Documents.chosen(this.model));
  },

  downloadViewer : function() {
    if (this.checkBusy()) return;
    this.model.downloadViewer();
  },

  // Open an edit dialog for the currently selected documents, if this
  // document is among them. Otherwise, open the dialog just for this document.
  openDialog : function(e) {
    if (!(this.modes.editable == 'is')) return;
    if (this.model.checkBusy()) return;
    dc.ui.DocumentDialog.open(this.model);
  },

  openEmbed : function() {
    if (!this.model.checkAllowedToEdit(Documents.EMBED_FORBIDDEN)) return;
    (new dc.ui.EmbedDialog(this.model)).render();
  },

  openPagesInViewer : function() {
    this.model.openViewer('#pages');
  },

  previousPage : function() {
    this._currentPage--;
    this._showPageImages();
  },

  nextPage : function() {
    this._currentPage++;
    this._showPageImages();
  },

  toggleNotes : function(e) {
    e.stopPropagation();
    var next = _.bind(function() {
      var model = Documents.get(this.model.id);
      if (this.modes.notes == 'has') return this.setMode('owns', 'notes');
      if (model.checkBusy()) return;
      if (model.notes.length && model.notes.length == this.model.get('annotation_count')) {
        return this.setMode('has', 'notes');
      }
      dc.ui.spinner.show('loading notes');
      model.notes.fetch({success : function() {
        dc.ui.spinner.hide();
        window.scroll(0, $('#document_' + model.id).offset().top - 100);
      }});
    }, this);
    dc.app.paginator.mini ? dc.app.paginator.toggleSize(next, this.model) : next();
  },

  deleteDocuments : function() {
    Documents.verifyDestroy(Documents.chosen(this.model));
  },

  searchAccount : function() {
    dc.app.searcher.addToSearch('account: ' + this.model.get('account_slug'));
  },

  searchOrganization : function() {
    dc.app.searcher.addToSearch('group: ' + this.model.get('organization_slug'));
  },

  searchSource : function() {
    dc.app.searcher.addToSearch('source: "' + this.model.get('source').replace(/"/g, '\\"') + '"');
  },

  editAccessLevel : function() {
    Documents.editAccess([this.model]);
  },

  setAccessLevelAll : function() {
    Documents.editAccess(Documents.chosen(this.model));
  },

  editPublishAt : function() {
    new dc.ui.PublicationDateDialog([this.model]);
  },

  openTroubleshooting : function() {
    dc.app.workspace.help.openPage('troubleshooting');
  },

  openContactUs : function() {
    dc.app.workspace.help.openContactDialog();
  },
  
  _openShareDialog : function() {
    // if (!Documents.allowedToEdit(this.model)) return;
    
    dc.app.shareDialog = new dc.ui.ShareDialog({'docs': [this.model]});
  },

  showMenu : function(e) {
    e.preventDefault();
    var menu = dc.ui.Document.sharedMenu || (dc.ui.Document.sharedMenu = new dc.ui.Menu({
      id : 'document_menu',
      standalone : true
    }));
    var count = Documents.chosen(this.model).length;
    if (!count) return;
    var deleteTitle = Inflector.pluralize('Delete Document', count);
    menu.clear();
    var items = [{title : 'Open', onClick: this.viewDocuments}];
    if (this.model.isPublished()) items.push({title : 'Open Published Version', onClick : this.viewPublishedDocuments});
    items.push({title : 'View Entities', onClick: this.viewEntities});
    if (this.model.allowedToEdit()) {
      items = items.concat([
        {title : 'Edit Document Information', onClick: this.openDialog},
        {title : 'Set Access Level',          onClick: this.setAccessLevelAll},
        {title : 'Embed Document Viewer',     onClick: this.openEmbed, attrs : {'class' : count > 1 ? 'disabled' : ''}},
        {title : deleteTitle,                 onClick: this.deleteDocuments, attrs : {'class' : 'warn'}}
      ]);
    }
    menu.addItems(items);
    menu.render().open().content.css({top : e.pageY, left : e.pageX});
  },

  _iconAttributes : function() {
    var access = this.model.get('access');
    var base = 'icon main_icon document_tool ';
    switch (access) {
      case dc.access.PENDING:      return {'class' : base + 'spinner',    title : 'Uploading...'};
      case dc.access.ERROR:        return {'class' : base + 'alert_gray', title : 'Broken document'};
      case dc.access.ORGANIZATION: return {'class' : base + 'lock',       title : 'Private to ' + dc.account.organization.name};
      case dc.access.PRIVATE:      return {'class' : base + 'lock',       title : 'Private'};
      default:
        if (this.model.isPublished()) return {'class' : base + 'published', title : 'Open Published Version'};
        return {'class' : base + 'hidden'};
    }
  },

  _thumbnailURL : function() {
    var access = this.model.get('access');
    switch (access) {
      case dc.access.PENDING: return '/images/embed/documents/processing.png';
      case dc.access.ERROR:   return '/images/embed/documents/failed.png';
      default:                return this.model.get('thumbnail_url');
    }
  },

  // HTML descriptions need to be sanitized for the workspace.
  _displayDescription : function() {
    var el = this.$('.description_text');
    if (this.model.get('access') == dc.access.ERROR) return el.html(this.ERROR_MESSAGE);
    el.text(Inflector.stripTags(this.model.get('description') || ''));
  },

  _setSelected : function() {
    var sel = this.model.get('selected');
    this.setMode(sel ? 'is' : 'not', 'selected');
  },

  _onDocumentChange : function() {
    if (this.model.hasChanged('selected')) return;
    this.render();
  },

  _addNote : function(note) {
    this.notesEl.append((new dc.ui.Note({model : note, collection : this.model.notes})).render().el);
  },

  _renderNotes : function() {
    this.notesEl.empty();
    this.model.notes.each(this._addNote);
    this.setMode('has', 'notes');
  },

  _togglePageImages : function() {
    if (this._showingPages) {
      this._hidePages();
      this._showingPages = false;
    } else {
      this._showPageImages();
      this._showingPages = true;
    }
  },

  _showPageImages : function() {
    var start = (this._currentPage * this.PAGE_LIMIT) + 1;
    var total = this.model.get('page_count');
    this.pagesEl.html(JST['document/page_images']({
      doc   : this.model,
      start : start,
      end   : Math.min(start + this.PAGE_LIMIT - 1, total),
      total : total,
      limit : this.PAGE_LIMIT
    }));
  },

  _renderPages : function() {
    this.pagesEl.html(JST['document/pages']({doc : this.model}));
  },

  _hidePages : function() {
    this._currentPage = 0;
    this.pagesEl.html('');
  },

  _openPage : function(e) {
    var el      = $(e.target).closest('.page');
    var page    = el.attr('data-page');
    var id      = el.attr('data-id');
    var offset  = el.attr('data-offset');
    if (id) {
      window.open(this.model.viewerUrl() + "?entity=" + id + '&page=' + page + '&offset=' + offset);
    } else {
      this.model.openViewer('#document/p' + page);
    }
  },

  // When the document is dropped onto a project, add it to the project.
  _onDrop : function(e) {
    var docs = [this.model];
    var selected = Documents.selected();
    if (selected.length && _.include(selected, this.model)) docs = selected;
    var x = e.pageX, y = e.pageY;
    $('#organizer .project').each(function() {
      var top = $(this).offset().top, left = $(this).offset().left;
      var right = left + $(this).outerWidth(), bottom = top + $(this).outerHeight();
      if (left < x && right > x && top < y && bottom > y) {
        var project = Projects.getByCid($(this).attr('data-project-cid'));
        if (project) project.addDocuments(docs);
        return false;
      }
    });
  },

  _noSelect : function(e) {
    e.preventDefault();
  }

});