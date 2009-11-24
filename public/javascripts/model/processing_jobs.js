// ProcessingJob Model

dc.model.ProcessingJob = dc.Model.extend({

  DOCUMENT_STATUSES : {
    loading    : "loading...",
    splitting  : "starting...",
    processing : "processing pages...",
    merging    : "extracting entities..."
  },

  constructor : function(options) {
    this.base(options);
    this.set({url : '/import/job_status/' + this.id + '.json'});
  },

  documentDisplayStatus : function() {
    return this.DOCUMENT_STATUSES[this.get('status')];
  },

  update : function() {
    $.get(this.get('url'), {}, _.bind(function(resp) {
      this.set(resp);
      if (_.isEqual(resp, {})) {
        return ProcessingJobs.remove(this);
        if (ProcessingJobs.size() <= 0) ProcessingJobs.stopUpdates();
      }
    }, this), 'json');
  }

});


// ProcessingJob Set

dc.model.ProcessingJobSet = dc.model.RESTfulSet.extend({

  resource : 'processing_jobs',

  UPDATE_INTERVAL : 5000,

  constructor : function(options) {
    this.base(options);
    _.bindAll('checkForUpdates', this);
  },

  startUpdates : function() {
    dc.ui.spinner.hide();
    this._poller = setInterval(this.checkForUpdates, this.UPDATE_INTERVAL);
  },

  stopUpdates : function() {
    clearInterval(this._poller);
    this._poller = null;
  },

  checkForUpdates : function() {
    _.invoke(this.models(), 'update');
  }

});

window.ProcessingJobs = new dc.model.ProcessingJobSet();
