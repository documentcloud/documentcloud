dc.ui.AnnotationEditor = Backbone.View.extend({

  id : 'annotation_editor',

  events : {
    'click .close': 'close'
  },

  constructor : function(options) {
    Backbone.View.call(this, options);
    this._open    = false;
    this._buttons = {};
    this._baseURL = '/documents/' + dc.app.editor.docId + '/annotations';
    this._inserts = $('.DV-pageNoteInsert');
    _.bindAll(this, 'open', 'close', 'drawAnnotation', 'saveAnnotation', 'deleteAnnotation', 'createPageNote');
    currentDocument.api.onAnnotationSave(this.saveAnnotation);
    currentDocument.api.onAnnotationDelete(this.deleteAnnotation);
    this._inserts.click(this.createPageNote);
  },

  open : function(kind) {
    this._open          = true;
    this._buttons[kind] = $('#control_panel .' + kind + '_annotation');
    this.pages          = $('.DV-pages');
    this.page           = $('.DV-page');
    this._guide         = $(kind == 'public' ? '#public_note_guide' : '#private_note_guide');
    this.page.css({cursor : 'crosshair'});
    this._inserts.filter('.visible').show().addClass('DV-' + kind);
    this.page.bind('mousedown', this.drawAnnotation);
    $(document).bind('keydown', this.close);
    this._buttons[kind].addClass('open');
    this._guide.fadeIn('fast');
  },

  close : function() {
    this._open = false;
    this.page.css({cursor : null});
    this.page.unbind('mousedown', this.drawAnnotation);
    $(document).unbind('keydown', this.close);
    this.clearAnnotation();
    this._inserts.hide().removeClass('DV-public DV-private');
    this._buttons[this._kind].removeClass('open');
    this._guide.hide();
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

  // When a page note insert line is clicked, create a page annotation above
  // the corresponding page.
  createPageNote : function(e) {
    this.close();
    var set = $(e.target).closest('.DV-set');
    var pageNumber = currentDocument.api.getPageNumberForId(set.attr('data-id'));
    currentDocument.api.addAnnotation({page : pageNumber, unsaved : true, access : this._kind || 'public'});
  },

  // TODO: Clean up!
  drawAnnotation : function(e) {
    e.stopPropagation();
    e.preventDefault();
    this._activePage = $(e.currentTarget);
    this.clearAnnotation();
    var offTop        = this.pages.scrollTop() - this.pages.offset().top,
        offLeft       = this.pages.scrollLeft() - this.pages.offset().left,
        ox            = e.pageX + offLeft,
        oy            = e.pageY + offTop,
        borderTop     = offTop + this._activePage.offset().top,
        borderLeft    = offLeft + this._activePage.offset().left,
        borderBottom  = borderTop + this._activePage.height() - 6,
        borderRight   = borderLeft + this._activePage.width() - 6;
    this.region = this.make('div', {
      'class' : 'DV-annotationRegion active ' + this._accessClass(this._kind), 
      style:'position:absolute;'
    });
    this.pages.append(this.region);
    var contained = function(e) {
      return e.pageX > borderLeft && e.pageX < borderRight &&
        e.pageY > borderTop && e.pageY < borderBottom;
    };
    var coords = function(e) {
      var x = e.pageX + offLeft,
          y = e.pageY + offTop;
      x = x < borderLeft ? borderLeft : (x > borderRight ? borderRight : x);
      y = y < borderTop ? borderTop : (y > borderBottom ? borderBottom : y);
      return {
        left    : Math.min(ox, x),
        top     : Math.min(oy, y),
        width   : Math.abs(x - ox),
        height  : Math.abs(y - oy)
      };
    };
    var drag = _.bind(function(e) {
      $(this.region).css(coords(e));
      return false;
    }, this);
    var dragEnd = _.bind(function(e) {
      $(document).unbind('keydown', this.close);
      this.pages.unbind('mouseup', dragEnd).unbind('mousemove', drag);
      var loc     = coords(e);
      loc.top     -= borderTop;
      loc.left    -= (borderLeft - 2);
      loc.right   = loc.left + loc.width + 13;
      loc.bottom  = loc.top + loc.height + 3;
      var zoom    = currentDocument.api.currentZoom();
      var image   = _.map([loc.top, loc.right, loc.bottom, loc.left], function(l){ return Math.round(l / zoom); }).join(',');
      this.close();
      if (loc.width > 10 && loc.height > 10) {
        var set = $(this._activePage).closest('.DV-set');
        var pageNumber = currentDocument.api.getPageNumberForId(set.attr('data-id'));
        currentDocument.api.addAnnotation({location : {image : image}, page : pageNumber, unsaved : true, access : this._kind});
      }
      return false;
    }, this);
    this.pages.bind('mouseup', dragEnd).bind('mousemove', drag);
  },

  saveAnnotation : function(anno) {
    if (!anno.location) currentDocument.api.redraw(true);
    this[anno.unsaved ? 'createAnnotation' : 'updateAnnotation'](anno);
  },

  // Convert an annotation object into serializable params understood by us.
  annotationToParams : function(anno, extra) {
    delete anno.unsaved;
    var params = {
      page_number : anno.page,
      content     : anno.text,
      title       : anno.title,
      access      : anno.access
    };
    if (anno.location) params.location = anno.location.image;
    return _.extend(params, extra || {});
  },

  createAnnotation : function(anno) {
    var params = this.annotationToParams(anno);
    $.ajax({url : this._baseURL, type : 'POST', data : params, dataType : 'json', success : _.bind(function(resp) {
      anno.server_id = resp.id;
      this._adjustNoteCount(1);
    }, this)});
  },

  updateAnnotation : function(anno) {
    var url = this._baseURL + '/' + anno.server_id;
    var params = this.annotationToParams(anno, {_method : 'put'});
    $.ajax({url : url, type : 'POST', data : params, dataType : 'json'});
  },

  deleteAnnotation : function(anno) {
    if (!anno.server_id) return;
    var url = this._baseURL + '/' + anno.server_id;
    $.ajax({url : url, type : 'POST', data : {_method : 'delete'}, dataType : 'json', success : _.bind(function() {
      this._adjustNoteCount(-1);
    }, this)});
  },

  _adjustNoteCount : function(num) {
    try {
      var id = parseInt(currentDocument.api.getId(), 10);
      var doc = window.opener.Documents.get(id);
      if (doc) doc.set({annotation_count : (doc.get('annotation_count') || 0) + num});
    } catch (e) {
      // It's ok -- we don't have access to the parent window.
    }
  },
  
  _accessClass : function(kind) {
    if (kind == 'public')         return 'DV-accessPublic';
    else if (kind =='exclusive')  return 'DV-accessExclusive';
    else if (kind =='private')    return 'DV-accessPrivate';
  }

});
