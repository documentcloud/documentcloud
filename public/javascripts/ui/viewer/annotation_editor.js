dc.ui.AnnotationEditor = dc.View.extend({

  id : 'annotation_editor',

  callbacks : {
    '.close.click': 'close'
  },

  constructor : function(opts) {
    this.base(opts);
    this._open    = false;
    this._buttons = {};
    this._baseURL = '/documents/' + dc.app.editor.docId + '/annotations';
    _.bindAll(this, 'open', 'close', 'drawAnnotation', 'saveAnnotation', 'deleteAnnotation');
    DV.api.onAnnotationSave(this.saveAnnotation);
    DV.api.onAnnotationDelete(this.deleteAnnotation);
  },

  open : function(kind) {
    this._open          = true;
    this._buttons[kind] = $('#control_panel .' + kind + '_annotation');
    this.pages          = $('#DV-pages');
    this.page           = $('.DV-page');
    this.page.css({cursor : 'crosshair'});
    this.page.bind('mousedown', this.drawAnnotation);
    $(document).bind('keydown', this.close);
    this._buttons[kind].addClass('open');
  },

  close : function() {
    this._open = false;
    this.page.css({cursor : null});
    this.page.unbind('mousedown', this.drawAnnotation);
    $(document).unbind('keydown', this.close);
    this.clearAnnotation();
    this._buttons[this._kind].removeClass('open');
  },

  toggle : function(kind) {
    if (this._open) {
      this.close();
      if (kind === this._kind) return;
    }
    this.open(this._kind = kind);
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
    this.region = $.el('div', {'class' : 'DV-annotationRegion active DV-' + this._kind});
    this.pages.append(this.region);
    var coords = function(e) {
      return {
        left    : Math.min(aleft, e.pageX + offLeft),
        top     : Math.min(atop, e.pageY + offTop),
        width   : Math.abs(e.pageX - ox),
        height  : Math.abs(e.pageY - oy)
      };
    };
    var drag = _.bind(function(e) {
      e.stopPropagation();
      e.preventDefault();
      $(this.region).css(coords(e));
    }, this);
    var dragEnd = _.bind(function(e) {
      e.stopPropagation();
      e.preventDefault();
      $(document).unbind('keydown', this.close);
      this.pages.unbind('mouseup', dragEnd).unbind('mousemove', drag);
      var loc     = coords(e);
      loc.top     -= (offTop + this._activePage.offset().top);
      loc.left    -= (offLeft + this._activePage.offset().left);
      loc.right   = loc.left + loc.width;
      loc.bottom  = loc.top + loc.height;
      var zoom    = DV.api.currentZoom();
      var image   = [loc.top / zoom, loc.right / zoom, loc.bottom / zoom, loc.left / zoom].join(',');
      this.close();
      if (loc.width > 10 && loc.height > 10) {
        DV.api.addAnnotation({location : {image : image}, page : DV.api.currentPage(), unsaved : true, access : this._kind});
      }
    }, this);
    this.pages.bind('mouseup', dragEnd).bind('mousemove', drag);
  },

  saveAnnotation : function(anno) {
    this[anno.unsaved ? 'createAnnotation' : 'updateAnnotation'](anno);
  },

  annotationToParams : function(anno, extra) {
    delete anno.unsaved;
    return _.extend({ json : JSON.stringify({
      location    : anno.location.image,
      page_number : anno.page,
      content     : anno.text,
      title       : anno.title,
      access      : anno.access == 'private' ? 1 : 4
    })}, extra || {});
  },

  createAnnotation : function(anno) {
    var params = this.annotationToParams(anno);
    $.ajax({url : this._baseURL, type : 'POST', data : params, dataType : 'json', success : function(resp) {
      anno.server_id = resp.id;
    }});
  },

  updateAnnotation : function(anno) {
    var url = this._baseURL + '/' + anno.server_id;
    var params = this.annotationToParams(anno, {_method : 'put'});
    $.ajax({url : url, type : 'POST', data : params, dataType : 'json'});
  },

  deleteAnnotation : function(anno) {
    var url = this._baseURL + '/' + anno.server_id;
    $.ajax({url : url, type : 'POST', data : {_method : 'delete'}, dataType : 'json'});
  }

});