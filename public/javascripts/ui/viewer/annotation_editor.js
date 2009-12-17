dc.ui.AnnotationEditor = dc.View.extend({

  id : 'annotation_editor',

  open : function() {
    $(this.el).html(JST.annotation_editor({}));
    $(document.body).append(this.el);
    $(this.el).align(document.body);
    $(this.el).draggable();
    // var json = eval(prompt('annotation json please:'));
    // this.addAnnotation(json);
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