dc.ui.UploadDialog = dc.ui.Dialog.extend({

  id : 'upload_dialog',

  callbacks : {
    '.ok.click':      'confirm',
    '.cancel.click':  'close'
  },

  constructor : function() {
    _.bindAll(this, '_onUploadStarted', '_onUploadCompleted', '_updateProgress');
    this.base({
      mode      : 'custom',
      title     : "Upload Documents"
    });
  },

  render : function() {
    $(this.el).hide();
    this.base();
    $('.custom', this.el).html(JST.upload_dialog({
      organization: dc.app.organization.name
    }));
    $('.cancel', this.el).text('close');
    $('.ok', this.el).text('upload');
    this.setCallbacks();
    this._observeUploadProgress();
    return this;
  },

  confirm : function() {
    dc.ui.spinner.show('uploading');
    $('#upload_document', this.el).submit();
    return true;
  },

  open : function() {
    $(this.el).show();
  },

  close : function() {
    ProcessingJobs.unbindAll();
    ProcessingJobs.stopUpdates();
    $(this.el).hide();
  },

  _observeUploadProgress : function() {
    ProcessingJobs.bind(dc.Set.MODEL_ADDED,   this._onUploadStarted);
    ProcessingJobs.bind(dc.Set.MODEL_REMOVED, this._onUploadCompleted);
    ProcessingJobs.bind(dc.Set.MODEL_CHANGED, this._updateProgress);
    if (ProcessingJobs.size()) {
      ProcessingJobs.each(_(function(job){ this._onUploadStarted(null, job); }).bind(this));
      ProcessingJobs.startUpdates();
    }
  },

  _onUploadStarted : function(e, model) {
    $('#upload_progress', this.el).append(JST.document_progress(model.attributes()));
    $('#upload_progress', this.el).show();
    $('#upload_info', this.el).show();
    $('input', this.el).val('');
    $('textarea', this.el).val('');
    this._updateProgress(e, model);
  },

  _onUploadCompleted : function(e, model) {
    var el = $('#document_progress_' + model.id);
    $('.progress_bar', el).css({width : '100%'});
    $('.status', el).html('complete');
  },

  _updateProgress : function(e, model) {
    var el = $('#document_progress_' + model.id);
    $('.status', el).html(model.documentDisplayStatus());
    $('.progress_bar', el).animate({width : model.get('percent_complete') + '%'});
  }

});
