dc.ui.AnnotationEditor = dc.View.extend({

  open : function() {
    var json = eval(prompt('annotation json please:'));
    this.addAnnotation(json);
  },

  addAnnotation : function(anno) {
    $.ajax({
      url       : '/documents/' + dc.app.editor.docId + '/annotations',
      type      : 'POST',
      data      : anno,
      dataType  : 'json'
    });
    dc.app.editor.notify({mode: 'info', text : 'annotation saved'});
    // this.updateNavigation(anno);
    return true;
  },

  updateNavigation : function(anno) {
    sections = _.map(sections, function(s){ return _.extend({pages : '' + s.start_page + '-' + s.end_page}, s); });
    DV.controller.setSections(sections);
  }

});