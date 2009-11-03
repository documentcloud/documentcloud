// The Sidebar. Switches contexts between different subviews.
dc.ui.DocumentUpload = dc.View.extend({
  
  className : 'document_upload panel',
  
  callbacks : [
    ['#upload_form',    'submit',   'beginUpload']
  ],
  
  constructor : function(options) {
    this.base(options);
    _.bindAll('_onUploadStarted', '_onUploadCompleted', '_updateProgress', this);
  },
  
  render : function() {
    var params = {organization : Accounts.current().get('organization_name')};
    $(this.el).html(dc.templates.DOCUMENT_UPLOAD_FORM(params));
    $('#document_upload_container').html(this.el);
    $('#upload_progress_container').html(dc.templates.DOCUMENT_PROGRESS_CONTAINER({}));
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
  },
  
  _onUploadStarted : function(e, model) {
    $('#upload_progress_inner').append(dc.templates.DOCUMENT_PROGRESS(model.attributes()));
    this._updateProgress(e, model);
  },
  
  _onUploadCompleted : function(e, model) {
    var el = $('#document_progress_' + model.id);
    $('.status', el).html('complete');
    $('.progress_bar', el).css({width : '100%'});
  },
  
  _updateProgress : function(e, model) {
    var el = $('#document_progress_' + model.id);
    $('.status', el).html(model.documentDisplayStatus());
    $('.progress_bar', el).animate({width : model.get('percent_complete') + '%'});
  }
  
});