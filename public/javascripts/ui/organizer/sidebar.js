dc.ui.OrganizerSidebar = dc.View.extend({
  
  id : 'organizer_sidebar',
  
  callbacks : [
    ['#new_label_button', 'click',    'saveNewLabel'],
    ['#label_input',      'keyup',    'onLabelInput']
  ],
  
  constructor : function(options) {
    this.base(options);
    this.organizer = this.options.organizer;
  },
  
  render : function() {
    $(this.el).append(dc.templates.ORGANIZER_SIDEBAR({}));
    this.labelInputEl = $('#label_input', this.el);
    this.setCallbacks();
    return this;
  },
  
  onLabelInput : function(e) {
    if (e.keyCode && e.keyCode === 13) return this.saveNewLabel(e);
    this.organizer.autofilter(this.labelInputEl.val());
  },
  
  saveNewLabel : function(e) {
    var me = this;
    var input = this.labelInputEl;
    var title = input.val();
    if (!title) return;
    if (Labels.find(title)) return this.warnAlreadyExists();
    input.val(null);
    input.focus();
    var label = new dc.model.Label({title : title});
    Labels.create(label, null, {error : function() { Labels.remove(label); }});
  },
  
  warnAlreadyExists : function() {
    dc.ui.notifier.show({text : 'label already exists', anchor : this.labelInputEl, position : '-left bottom', top : 6, left : 1});
  }
  
});

