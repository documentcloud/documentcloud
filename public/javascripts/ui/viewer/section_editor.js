dc.ui.SectionEditor = dc.View.extend({

  constructor : function(opts) {
    this.base(opts);
    _.bindAll(this, 'addRow', 'saveSections', 'removeAllSections');
  },

  open : function() {
    if (this.dialog) return false;
    this.sections = _.sortBy(DV.api.getSections(), function(s){ return parseInt(s.pageNumber, 10); });
    this.dialog = new dc.ui.Dialog({
      title       : 'Edit Sections',
      information : 'Please choose a title and page range for each section.',
      id          : 'section_editor',
      mode        : 'confirm',
      onClose     : _.bind(function(){ this.dialog = null; }, this),
      onConfirm   : _.bind(function(){ return this.saveSections(this.serializeSections()); }, this)
    }).render();
    $('.minibutton.ok span', this.dialog.el).text('save');
    this.sectionsEl = $($.el('ol', {id : 'section_rows'}));
    this.removeEl   = $($.el('div', {'class' : 'minibutton warn remove_all'}, 'Remove All'));
    this.removeEl.bind('click', this.removeAllSections);
    this.dialog.append(this.sectionsEl);
    this.dialog.appendControl(this.removeEl);
    this.renderSections();
  },

  validateSections : function(sections) {
    var valid = _.all(sections, function(sec) { return sec.start_page <= sec.end_page; });
    if (!valid) return alert("Sections cannot end before they start.");
    return true;
  },

  saveSections : function(sections) {
    if (!this.validateSections(sections)) return false;
    $.ajax({
      url       : '/sections/set',
      type      : 'POST',
      data      : {sections : JSON.stringify(sections), document_id : dc.app.editor.docId},
      dataType  : 'json'
    });
    this.updateNavigation(sections);
    return true;
  },

  removeAllSections : function() {
    this.saveSections([]);
    this.dialog.close();
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

  renderSections : function() {
    var me = this;
    if (!_.any(this.sections)) return _.each(_.range(3), function(){ me.addRow(); });
    _.each(this.sections, function(sec) {
      var pages = sec.pages.split('-');
      me.addRow({title : sec.title, start_page : parseInt(pages[0], 10), end_page : parseInt(pages[1], 10)});
    });
  },

  updateNavigation : function(sections) {
    sections = _.map(sections, function(s){ return _.extend({pages : '' + s.start_page + '-' + s.end_page}, s); });
    DV.api.setSections(sections);
  },

  addRow : function(options) {
    options = _.extend({pageCount : DV.api.numberOfPages(), title : '', start_page : '', end_page : ''}, options);
    var row = $(JST.section_row(options));
    $('.section_title', row).val(options.title);
    $('.minus', row).bind('click', function(){ row.remove(); });
    $('.plus', row).bind('click', _.bind(function(){ this.addRow({after : row}); }, this));
    if (options.after) return options.after.after(row);
    this.sectionsEl.append(row);
  }

});