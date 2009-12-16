dc.ui.ViewerControlPanel = dc.View.extend({

  id : 'control_panel',

  callbacks : [
    ['#bookmark_page',  'click',  'bookmarkCurrentPage'],
    ['#set_sections',   'click',  'openSectionEditor']
  ],

  constructor : function(opts) {
    this.base(opts);
    _.bindAll(this, 'addSectionRow', 'saveSections');
  },

  render : function() {
    $(this.el).html(JST.viewer_control_panel({}));
    this.setCallbacks();
    return this;
  },

  notify : function(options) {
    dc.ui.notifier.show({
      mode      : options.mode,
      text      : options.text,
      anchor    : $('#DV-views'),
      position  : 'center right',
      left      : 10
    });
  },

  saveSections : function() {
    var sections = this.serializeSections();
    // if (!this.validateSections(sections)) return false; TBI
    $.ajax({
      url       : '/sections/set',
      type      : 'POST',
      data      : {sections : JSON.stringify(sections), document_id : dc.app.editor.docId},
      dataType  : 'json'
    });
    this.notify({mode: 'info', text : 'sections saved'});
    return true;
  },

  serializeSections : function() {
    var sections = [];
    $('.section_row').each(function(i, row) {
      var title = $('input', row).val();
      var first = parseInt($('.start_page', row).val(), 10);
      var last  = parseInt($('.end_page', row).val(), 10);
      if (title) sections.push({title : title, start_page : first, end_page : last});
    });
    return sections;
  },

  openSectionEditor : function() {
    if (this.sectionEditor) return false;
    this.sectionEditor = new dc.ui.Dialog({
      id        : 'section_editor',
      mode      : 'confirm',
      buttons   : 'mini',
      title     : 'Edit Sections',
      text      : 'Please choose a title and page range for each section:',
      onClose   : _.bind(function(){ this.sectionEditor = null; }, this),
      onConfirm : this.saveSections
    }).render();
    this.sections = $($.el('ol', {id : 'section_rows'}));
    this.sectionEditor.append(this.sections);
    _.each(_.range(3), this.addSectionRow);
  },

  addSectionRow : function(previous) {
    var pages = DV.controller.models.document.totalPages;
    var row = $(JST.section_row({pageCount : pages}));
    $('.minus', row).bind('click', function(){ row.remove(); });
    $('.plus', row).bind('click', _.bind(function(){ this.addSectionRow(row); }, this));
    if (previous.after) return previous.after(row);
    this.sections.append(row);
  },

  bookmarkCurrentPage : function() {
    var bookmark = new dc.model.Bookmark({
      title       : DV.Schema.data.title,
      page_number : DV.controller.models.document.currentPage(),
      document_id : dc.app.editor.docId
    });
    var openerMarks = (window.opener && window.opener.Bookmarks);
    Bookmarks.create(bookmark, null, {
      success : _.bind(function(model, resp) {
        bookmark.set(resp);
        if (openerMarks) openerMarks.add(bookmark);
        this.notify({mode: 'info', text : 'bookmark saved'});
      }, this),
      error : _.bind(function() {
        this.notify({mode : 'warn', text : 'bookmark already exists'});
      }, this)
    });
  }

});