// The Sidebar. Switches contexts between different subviews.
dc.ui.DocumentUpload = dc.View.extend({

  className : 'document_upload panel',

  callbacks : [
    ['#upload_form',    'submit',   'beginUpload']
  ],

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, '_onUploadStarted', '_onUploadCompleted', '_updateProgress');
  },

  render : function() {
    $(this.el).html(JST.document_upload_form({organization : dc.app.organization.name}));
    $('#document_upload_container').html(this.el);
    $('#upload_progress_container').html(JST.document_progress_container({}));
    this.setCallbacks();
    this._observeUploadProgress();
    return this;
  },

  beginUpload : function() {
    dc.ui.spinner.show('uploading document');
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
    $('#no_uploads').hide();
    $('#upload_progress_inner').append(JST.document_progress(model.attributes()));
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