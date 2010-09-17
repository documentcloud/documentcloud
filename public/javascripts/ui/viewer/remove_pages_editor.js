dc.ui.RemovePagesEditor = dc.View.extend({
  
  id : 'remove_pages_container',
  
  flags : {
    open: false
  },
  
  constructor : function(opts) {
    this.base(opts);
    _.bindAll(this);
  },

  toggle : function() {
    if (this.flags.open) {
      this.close();
    } else {
      this.open();
    }
  },
  
  findSelectors : function() {
    this.$s = {
      guide : $('#edit_remove_pages_guide'),
      guideButton: $('.edit_remove_pages'),
      page : $('.DV-page'),
      pages : $('.DV-pages'),
      viewerContainer : $('.DV-docViewer-Container')
    };
    
    this.viewer = DV.viewers[_.first(_.keys(DV.viewers))];
  },
  
  open : function() {
    this.findSelectors();
    this.flags.open = true;
    this.$s.guide.fadeIn('fast');
    this.$s.guideButton.addClass('open');
    this.render();
    this.setCallbacks();
  },
  
  render : function() {
    $(this.el).html(JST['viewer/remove_pages']({}));
    console.log(['remove_pages', this.el, this.viewer]);
    this.$s.viewerContainer.append(this.el);
    this.viewer.open('ViewDocument');
    this.$s.pages.addClass('remove_pages_viewer');
  },
  
  setCallbacks : function() {
    $('.DV-pageCollection').delegate('.DV-page','click', _.bind(function(e) {
      this.addPageToRemoveSet(e.target);
    }, this));
  },
  
  addPageToRemoveSet : function(cover) {
    var $page = $(cover).parents('.DV-page').eq(0);
    console.log(['page', $page]);
    $('.remove_pages_holder', this.el).append($page);
  },
  
  close : function() {
    this.flags.open = false;
    this.$s.guide.fadeOut('fast');
    this.$s.guideButton.removeClass('open');
    this.$s.pages.removeClass('remove_pages_viewer');
    $(this.el).remove();
    this.base();
  }

});