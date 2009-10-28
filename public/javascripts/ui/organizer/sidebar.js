dc.ui.OrganizerSidebar = dc.View.extend({
  
  id : 'organizer_sidebar',
  
  callbacks : [
    ['#new_label_button', 'click',    'saveNewLabel'],
    ['#new_label',        'keypress', 'saveNewLabel']
  ],
  
  constructor : function(options) {
    this.base(options);
    // _.bindAll('ensurePopulated', '_addLabel', '_addSavedSearch', '_removeSubView', this);
  },
  
  render : function() {
    $(this.el).append(dc.templates.ORGANIZER_SIDEBAR({}));
    this.newLabelEl = $('#new_label', this.el);
    this.setCallbacks();
    return this;
  },
  
  saveNewLabel : function(e) {
    if (e.keyCode && e.keyCode != 13) return;
    var me = this;
    var input = this.newLabelEl;
    var title = input.val();
    if (!title) return;
    if (Labels.find(title)) return this.warnAlreadyExists();
    input.val(null);
    input.focus();
    var label = new dc.model.Label({title : title});
    Labels.create(label, null, {error : function() { Labels.remove(label); }});
  },
  
  warnAlreadyExists : function() {
    dc.ui.notifier.show({text : 'label already exists', anchor : this.newLabelEl, position : '-left bottom', top : 6, left : 1});
  }
  
});

