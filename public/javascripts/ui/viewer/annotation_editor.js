dc.ui.AnnotationEditor = dc.View.extend({

  id : 'annotation_editor',

  callbacks : [
    ['.close',    'click',    'close']
  ],

  constructor : function(opts) {
    this.base(opts);
    this._open = false;
    _.bindAll(this, 'open', 'close', 'drawAnnotation');
  },

  open : function() {
    // $(this.el).html(JST.annotation_editor({}));
    // $(document.body).append(this.el);
    // $(this.el).align(document.body);
    // $(this.el).draggable();
    // this.setCallbacks();
    this._open   = true;
    this._button = $('#control_panel .add_annotation');
    this.pages   = $('#DV-pages');
    this.page    = $('.DV-page');
    this.page.css({cursor : 'crosshair'});
    this.page.bind('mousedown', this.drawAnnotation);
    this._button.addClass('open');
    // var json = eval(prompt('annotation json please:'));
    // this.addAnnotation(json);
  },

  close : function() {
    this._open = false;
    this.page.css({cursor : null});
    this.page.unbind('mousedown', this.drawAnnotation);
    this.clearAnnotation();
    this._button.removeClass('open');
    // $(this.el).remove();
  },

  toggle : function() {
    this._open ? this.close() : this.open();
  },

  clearAnnotation : function() {
    if (this.region) $(this.region).remove();
  },

  // TODO: Clean up!
  drawAnnotation : function(e) {
    e.stopPropagation();
    e.preventDefault();
    this._activePage = $(e.target);
    this.clearAnnotation();
    var offTop  = this.pages.scrollTop() - this.pages.offset().top,
        offLeft = this.pages.scrollLeft() - this.pages.offset().left;
    var ox = e.pageX, oy = e.pageY;
    var atop    = oy + offTop,
        aleft   = ox + offLeft;
    this.region = $.el('div', {'class' : 'DV-annotationRegion active'});
    this.pages.append(this.region);
    $(this.region).css({left : aleft, top : atop});
    var drag = _.bind(function(e) {
      e.stopPropagation();
      e.preventDefault();
      $(this.region).css({width : e.pageX - ox, height : e.pageY - oy});
    }, this);
    var dragEnd = _.bind(function(e) {
      e.stopPropagation();
      e.preventDefault();
      this.pages.unbind('mouseup', dragEnd).unbind('mousemove', drag);
      atop  -= (offTop + this._activePage.offset().top);
      aleft -= (offLeft + this._activePage.offset().left);
      var loc = [atop, aleft + $(this.region).width(), atop + $(this.region).height(), aleft].join(',');
      this.addAnnotation({location : loc, page_number : DV.api.currentPage()});
    }, this);
    this.pages.bind('mouseup', dragEnd).bind('mousemove', drag);
  },

  addAnnotation : function(anno) {
    var title = prompt("Title:");
    var content = prompt("Content:");
    var anno = _.extend(anno, {title : title, content : content});
    this.close();
    $.ajax({
      url       : '/documents/' + dc.app.editor.docId + '/annotations',
      type      : 'POST',
      data      : anno,
      dataType  : 'json'
    });
    dc.app.editor.notify({mode: 'info', text : 'annotation saved'});
    this.addAnnotationToViewer(anno);
    return true;
  },

  addAnnotationToViewer : function(anno) {
    anno.page = anno.page_number;
    anno.location = {image : anno.location};
    DV.api.addAnnotation(anno);
  }

});