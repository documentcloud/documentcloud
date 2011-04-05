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
    this.redactions = [];
    _.bindAll(this, 'open', 'close', 'drawAnnotation', 'saveAnnotation',
      'deleteAnnotation', 'createPageNote');
    currentDocument.api.onAnnotationSave(this.saveAnnotation);
    currentDocument.api.onAnnotationDelete(this.deleteAnnotation);
    this._inserts.click(this.createPageNote);
  },

  open : function(kind) {
    this._open          = true;
    this._buttons[kind] = $('#control_panel .' + kind + '_annotation');
    this.pages          = $('.DV-pages');
    this.page           = $('.DV-page');
    this._guide         = $('#' + kind + '_note_guide');
    this.redactions     = [];
    this.page.css({cursor : 'crosshair'});
    if (kind != 'redact') this._inserts.filter('.visible').show().addClass('DV-' + kind);
    this.page.bind('mousedown', this.drawAnnotation);
    $(document).bind('keydown', this.close);
    this._buttons[kind].addClass('open');
    this._guide.fadeIn('fast');
  },

  close : function() {
    this._open = false;
    this.page.css({cursor : ''});
    this.page.unbind('mousedown', this.drawAnnotation);
    $(document).unbind('keydown', this.close);
    this.clearAnnotation();
    this.clearRedactions();
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

  clearRedactions : function() {
    $('.DV-annotationRegion.DV-accessRedact').remove();
  },

  // When a page note insert line is clicked, create a page annotation above
  // the corresponding page.
  createPageNote : function(e) {
    this.close();
    var set = $(e.target).closest('.DV-set');
    var pageNumber = currentDocument.api.getPageNumberForId(set.attr('data-id'));
    currentDocument.api.addAnnotation({
      page            : pageNumber,
      unsaved         : true,
      access          : this._kind || 'public',
      owns_note       : true
    });
  },

  // TODO: Clean up!
  drawAnnotation : function(e) {
    e.stopPropagation();
    e.preventDefault();
    this._activePage = $(e.currentTarget);
    this._activePageNumber = currentDocument.api.getPageNumberForId($(this._activePage).closest('.DV-set').attr('data-id'));
    this.clearAnnotation();
    var offTop        = this._activePage.offset().top,
        offLeft       = this._activePage.offset().left,
        ox            = e.pageX - offLeft,
        oy            = e.pageY - offTop,
        borderBottom  = this._activePage.height() - 6,
        borderRight   = this._activePage.width() - 6;
    this.region = this.make('div', {'class' : 'DV-annotationRegion active ' + this._accessClass(this._kind), style:'position:absolute;'});
    (this._kind == 'redact' ? this._specificPage() : this._activePage).append(this.region);
    var contained = function(e) {
      return e.pageX > 0 && e.pageX < borderRight &&
             e.pageY > 0 && e.pageY < borderBottom;
    };
    var coords = function(e) {
      var x = e.pageX - offLeft - 3,
          y = e.pageY - offTop - 3;
      x = x < 0 ? 0 : (x > borderRight ? borderRight : x);
      y = y < 0 ? 0 : (y > borderBottom ? borderBottom : y);
      return {
        left    : Math.min(ox, x),
        top     : Math.min(oy, y),
        width   : Math.abs(x - ox),
        height  : Math.abs(y - oy)
      };
    };
    $(this.region).css(coords(e));
    var drag = _.bind(function(e) {
      $(this.region).css(coords(e));
      return false;
    }, this);
    var dragEnd = _.bind(function(e) {
      $(document).unbind('keydown', this.close);
      this.pages.unbind('mouseup', dragEnd).unbind('mousemove', drag);
      var loc     = coords(e);
      loc.top     += 1;
      loc.left    += 3;
      loc.right   = loc.left + loc.width + 11;
      loc.bottom  = loc.top + loc.height + 3;
      var zoom    = currentDocument.api.relativeZoom();
      var image   = _.map([loc.top, loc.right, loc.bottom, loc.left], function(l){ return Math.round(l / zoom); }).join(',');
      if (this._kind == 'redact') {
        if (loc.width > 5 && loc.height > 5) {
          this.redactions.push({
            location: image,
            page: this._activePageNumber
          });
        } else {
          $(this.region).remove();
        }
        this.region = null;
      } else {
        this.close();
        if (loc.width > 5 && loc.height > 5) {
          currentDocument.api.addAnnotation({
            location        : {image : image},
            page            : this._activePageNumber,
            unsaved         : true,
            access          : this._kind,
            owns_note       : true
          });
        }
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
    var url     = this._baseURL + '/' + anno.server_id;
    var params  = this.annotationToParams(anno, {_method : 'put'});
    $.ajax({url : url, type : 'POST', data : params, dataType : 'json'});
  },

  deleteAnnotation : function(anno) {
    if (!anno.server_id) return;
    var url = this._baseURL + '/' + anno.server_id;
    $.ajax({url : url, type : 'POST', data : {_method : 'delete'}, dataType : 'json', success : _.bind(function() {
      this._adjustNoteCount(-1);
    }, this)});
  },

  // Lazily create the page-specific div for persistent elements.
  _specificPage : function() {
    var already = $('.DV-pageSpecific-' + this._activePageNumber);
    if (already.length) return already;
    var el = this.make('div', {'class' : 'DV-pageSpecific DV-pageSpecific-' + this._activePageNumber});
    this._activePage.append(el);
    return $(el);
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
    return 'DV-access' + dc.inflector.capitalize(kind);
  }

});
