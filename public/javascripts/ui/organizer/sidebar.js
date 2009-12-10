dc.ui.OrganizerSidebar = dc.View.extend({

  id : 'organizer_sidebar',

  callbacks : [
    ['#new_label_button', 'click',    'saveNewLabel'],
    ['#label_input',      'keyup',    'onLabelInput'],
    ['#filter_box',       'keyup',    'autofilter']
  ],

  constructor : function(options) {
    this.base(options);
    this.organizer = this.options.organizer;
  },

  render : function() {
    $(this.el).append(JST.organizer_sidebar({}));
    this.labelInputEl = $('#label_input', this.el);
    this.filterEl = $('#filter_box', this.el);
    this.setCallbacks();
    return this;
  },

  autofilter : function(e) {
    this.organizer.autofilter(this.filterEl.val());
  },

  onLabelInput : function(e) {
    if (e.keyCode && e.keyCode === 13) return this.saveNewLabel(e);
  },

  saveNewLabel : function(e) {
    var me = this;
    var input = this.labelInputEl;
    var title = input.val();
    if (!title) return;
    if (Labels.find(title)) return this.warnAlreadyExists();
    input.val(null);
    input.focus();
    this.organizer.autofilter('');
    var label = new dc.model.Label({title : title});
    Labels.create(label, null, {error : function() { Labels.remove(label); }});
  },

  warnAlreadyExists : function() {
    dc.ui.notifier.show({text : 'label already exists', anchor : this.labelInputEl, position : '-left bottom', top : 6, left : 1});
  }

});

