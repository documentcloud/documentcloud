dc.ui.Admin = Backbone.View.extend({

  initialize : function(options) {
    _.bindAll(this, 'launchWorker', 'reprocessFailedDocument', 'vacuumAnalyze', 'optimizeSolr', 'forceBackup');
    this._actionsMenu = this._createActionsMenu();
    $('#topbar').append(this._actionsMenu.render().el);
  },

  render : function() {},

  launchWorker : function() {
    dc.ui.Dialog.confirm('Are you sure you want to launch a new Medium Compute<br />\
      EC2 instance for document processing, on <b>production</b>?', function() {
      $.post('/admin/launch_worker', function() {
        dc.ui.Dialog.alert(
          'The worker instance has been launched successfully.\
          It will be a few minutes before it comes online and registers with CloudCrowd.'
        );
      });
      return true;
    });
  },

  vacuumAnalyze : function() {
    $.post('/admin/vacuum_analyze', function() {
      dc.ui.Dialog.alert('The vacuum background job was started successfully.');
    });
  },

  optimizeSolr : function() {
    $.post('/admin/optimize_solr', function() {
      dc.ui.Dialog.alert('The Solr optimization task was started successfully.');
    });
  },

  forceBackup : function() {
    $.post('/admin/force_backup', function() {
      dc.ui.Dialog.alert('The database backup job was started successfully.');
    });
  },

  reprocessFailedDocument : function() {
    dc.ui.Dialog.confirm('Are you sure you want to re-import the last failed document?', function() {
      $.post('/admin/reprocess_failed_document', function() {
        window.location.reload(true);
      });
      return true;
    });
  },

  _createActionsMenu : function() {
    return new dc.ui.Menu({
      label   : 'Administrative Actions',
      id      : 'admin_actions',
      items   : [
        {title : 'Dashboard',                 onClick : function(){ window.location = '/admin/'; }},
        {title : 'Tools',                     onClick : function(){ window.location = '/admin/tools'; }},
        {title : 'Add Organization',          onClick : function(){ window.location = '/admin/signup'; }},
        {title : 'Modify Organization',       onClick : function(){ window.location = '/admin/organizations'; }},
        {title : 'Modify Memberships',        onClick : function(){ window.location = '/admin/memberships'; }},
        {title : 'Download Document Hits',    onClick : function(){ window.location = '/admin/document_hits'; }},
        {title : 'View CloudCrowd Console',   onClick : function(){ window.location = CLOUD_CROWD_SERVER; }},
        {title : 'Reprocess Last Failed Doc', onClick : this.reprocessFailedDocument},
        {title : 'Force a DB Backup to S3',   onClick : this.forceBackup},
        {title : 'Vacuum Analyze the DB',     onClick : this.vacuumAnalyze},
        {title : 'Optimize the Solr Index',   onClick : this.optimizeSolr},
        {title : 'Launch a Worker Instance',  onClick : this.launchWorker},
        {title : 'Edit Featured Reporting',   onClick : function(){ window.location = '/admin/featured'; }},
        {title : 'Update Dashboard Stats',    onClick : function(){ window.location = '/admin/expire_stats'; }}
      ]
    });
  },

});
