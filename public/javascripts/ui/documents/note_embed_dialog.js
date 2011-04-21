dc.ui.NoteEmbedDialog = dc.ui.Dialog.extend({

  events : {
    'change select'         : 'update',
    'click select'          : 'update',
    'click .next'           : 'nextStep',
    'click .previous'       : 'previousStep',
    'click .close'          : 'close',
    'click .snippet'        : 'selectSnippet'
  },

  totalSteps : 2,

  STEPS : [null,
    'Step One: Configure the Embedded Annotation',
    'Step Two: Copy and Paste the Embed Code'
  ],

  DEMO_ERROR : 'Demo accounts are not allowed to embed annotations. <a href="/contact">Contact us</a> if you need a full featured account. View an example of the embed code <a href="http://dev.dcloud.org/help/publishing#step_5">here</a>.',

  DEFAULT_OPTIONS : {},

  constructor : function(doc) {
    this.currentStep = 1;
    this.doc         = doc;
    this.height      = 0;
    dc.ui.Dialog.call(this, {mode : 'custom', title : this.displayTitle()});
    dc.ui.spinner.show();
    this.fetchNotes();
  },

  fetchNotes : function() {
    this.doc.notes.fetch({
      silent  : true,
      success : _.bind(function() {
        dc.ui.spinner.hide();
        this.render();
      }, this)
    });
  },

  render : function() {
    if (dc.account.organization.demo) return dc.ui.Dialog.alert(this.DEMO_ERROR);
    dc.ui.Dialog.prototype.render.call(this);
    this.$('.custom').html(JST['workspace/note_embed_dialog']({
      doc : this.doc
    }));
    this._next          = this.$('.next');
    this._previous      = this.$('.previous');
    this._noteSelectEl  = this.$('select[name=note]');
    this._preview       = this.$('.note_preview');
    this.setMode('embed', 'dialog');
    this.setMode('note_embed', 'dialog');
    this.update();
    this.setStep();
    this.center();
    dc.ui.spinner.hide();
    return this;
  },

  displayTitle : function() {
    return this.STEPS[this.currentStep];
  },

  update : function() {
    var id = parseInt(this._noteSelectEl.val(), 10);
    this.note = this.doc.notes.get(id);
    this._renderNote();
    this._renderEmbedCode();
    if (this._preview.height() > this.height) {
      this.center();
      this.height = this._preview.height();
    }
  },
  
  _renderNote : function() {
    var noteView = new dc.ui.Note({
      model       : this.note,
      collection  : this.doc.notes
    });
    this.$('.note_preview').html(noteView.render().el);
    noteView.center();
  },

  embedOptions : function() {
    var options = {
      note_id     : this.note.get('id'),
      document_id : this.doc.get('id')
    };
    return options;
  },

  _renderEmbedCode : function() {
    var options          = this.embedOptions();
    var serialized       = _.map(options, function(value, key){ return key + ': ' + value; });
    this.$('.publish_embed_code').html(JST['workspace/note_embed_code']({
      note    : this.note,
      options : serialized.join(',&#10;    ')
    }));
  },

  nextStep : function() {
    this.currentStep += 1;
    if (this.currentStep > this.totalSteps) return this.close();
    if (this.currentStep == 2) this.update();
    this.setStep();
  },

  previousStep : function() {
    if (this.currentStep > 1) this.currentStep -= 1;
    this.setStep();
  },

  setStep : function() {
    this.title(this.displayTitle());

    this.$('.publish_step').setMode('not', 'enabled');
    this.$('.publish_step_'+this.currentStep).setMode('is', 'enabled');
    this.info('Step ' + this.currentStep + ' of ' + this.totalSteps, true);

    var first = this.currentStep == 1;
    var last = this.currentStep == this.totalSteps;

    this._previous.setMode(first ? 'not' : 'is', 'enabled');
    this._next.html(last ? 'Finish' : 'Next &raquo;').setMode('is', 'enabled');
  },

  selectSnippet : function() {
    this.$('.snippet').select();
  }

});