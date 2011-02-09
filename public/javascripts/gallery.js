(function($) { 

  /* 
   * Some easing functions borrowed from the effects library to save loading the whole lot.
   * Glide is really quartic out. Boing is back out. Bounce is bounce out.
   */

  $.easing.glide = function (x, t, b, c, d) {
    return -c * ((t=t/d-1)*t*t*t - 1) + b;
  }
  
  $.easing.boing = function (x, t, b, c, d, s) {
    if (s == undefined) s = 1.70158;
    return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
  };

  function Gallery() {
    var self = this;
    var container = $('<div class="gallery"><img class="preview" /><p class="caption" /><div class="controls"><a href="#" class="previous" /><a href="#" class="download" /><a href="#" class="next" /></a></div><div class="closer"><a href="#" /></div></div>').hide().appendTo($('body'));
    $.extend(self, {
      container: container,
      zoomer: new Zoomer(),
      image: container.find('img.preview'),
      caption: container.find('p.caption'),
      controls: container.find('div.controls'),
      closer: container.find('div.closer'),
      stack: [],
      item: null,
      click_outside: null,
      escape_key: null,
      add: function (a) {
        self.stack.push(new GalleryItem(a));
      },
      display: function (item) {
        self.item = item;
        if (self.visible()) self.crossfade();
        else self.zoomUp();
      },
      
      mimic: function () {
        self.zoomer.setImage(self.item.src);
        self.image.attr('src', self.item.src);
        self.controls.find('a.download').attr('href', self.item.download_url());
        if (self.item.caption.html()) self.caption.html(self.item.caption.html()).show();
        else self.caption.hide();
      },
      zoomUp: function () {
        self.hide();
        self.mimic();
        self.zoomer.zoomUp(self.item, self.show);
        self.setClosers();
      },
      zoomDown: function () {
        self.zoomer.zoomDown(self.item);
        self.unsetClosers();
        self.hide();
      },
      crossfade: function () {
        self.fadeDown(self.fadeUp);
      },
      fadeDown: function (onFade) {
        self.caption.fadeTo('fast', 0.2);
        self.image.fadeTo('fast', 0.2, onFade);
      },
      fadeUp: function (onFade) {
        self.mimic();
        self.resize();
        self.caption.fadeTo('fast', 1);
        self.image.fadeTo('fast', 1, onFade);
      },

      current: function () {
        return self.stack.indexOf(self.item);
      },
      next: function (e) {
        if (e) e.preventDefault();
        var at = self.current();
        var next = (at == self.stack.length-1) ? 0 : at + 1;
        self.display(self.stack[next]);
      },
      previous: function (e) {
        if (e) e.preventDefault();
        var at = self.current();
        var previous = (at == 0) ? self.stack.length-1 : at - 1;
        self.display(self.stack[previous]);
      },
      close: function (e) {
        if (e) e.preventDefault();
        if (self.visible) self.zoomDown();
      },
      setClosers: function (argument) {
        self.escape_key = $(document).keyup(function(e) {
          if (e.keyCode == 27) self.close(e);
          if (!e.metaKey) {
            if (e.keyCode == 39) self.next(e);
            if (e.keyCode == 37) self.previous(e);
          }
          return false;
        });
      },
      unsetClosers: function (argument) {
        if (self.escape_key) $(document).unbind('keyup', self.escape_key);
      },


      show: function () {
        self.zoomer.hide();
        self.container.show();
      },
      hide: function () {
        self.container.hide();
      },
      visible: function () {
        return self.container.is(':visible');
      },
      showControls: function (e) {
        self.controls.fadeIn("fast");
        self.closer.fadeIn("fast");
      },
      hideControls: function (e) {
        self.controls.fadeOut("fast");
        self.closer.fadeOut("fast");
      },
      
      resize: function (item) {
        if (!item) item = self.item;
        var w = $(window);
        var d = item.imageSize();
        var p = self.container.offset();
        var r = {
          left: p.left + (self.image.innerWidth() - d.width)/2,
          top: p.top + (self.image.innerHeight() - d.height)/2
        };
        if (r.top <= 10) r.top = 10;
        self.image.animate(d, 'fast');
        self.container.animate(r, 'fast');
        self.controls.css({left: (d.width - 96)/2});
      },
      reposition: function (item) {
        if (!item) item = self.item;
        var w = $(window);
        var d = item.imageSize();
        var p = {
          top: w.scrollTop() + (w.height() - d.height)/2,
          left: w.scrollLeft() + (w.width() - d.width)/2
        };
        if (p.top <= 10) p.top = 10;
        if (self.visible) {
          self.image.animate(d, 'fast');
          self.container.animate(p, 'fast');
        } else {
          self.image.css(d);
          self.container.css(p);
        }
        self.controls.css({left: (d.width - 96)/2});
        return $.extend(d,p);
      },
      currentPosition: function () {
        var p = self.container.offset();
        return {
          left: p.left,
          top: p.top,
          width: self.image.innerWidth(),
          height: self.image.innerHeight()
        };
      }
    });
    
    self.closer.find('a').click(self.close);
    self.controls.find('a.previous').click(self.previous);
    self.controls.find('a.next').click(self.next);
    self.container.hover(self.showControls, self.hideControls);
  };
  
  function Zoomer() {
    var self = this;
    var sprite = $('<img class="grower" />').hide().appendTo($('body'));
    $.extend(self, {
      sprite: sprite,
      defaultUpState: {position: 'absolute', opacity: 1, borderLeftWidth: 20, borderRightWidth: 20, borderTopWidth: 20, borderBottomWidth: 20},
      defaultDownState: {position: 'absolute', opacity: 0, borderLeftWidth: 4, borderRightWidth: 4, borderTopWidth: 4, borderBottomWidth: 4},
      zoomDuration: 'slow',
      setImage: function (src) {
        self.sprite.attr('src', src);
      },
      zoomUp: function (item, onZoom) {
        if (!onZoom) onZoom = self.hide;
        self.sprite.css($.extend(self.defaultDownState, item.position()));
        self.show();
        self.sprite.animate($.extend({}, self.defaultUpState, $.gallery.reposition()), self.zoomDuration, onZoom);
      },
      zoomDown: function (item, onZoom) {
        if (!onZoom) onZoom = self.hide;
        self.interrupt();
        self.show();
        self.sprite.css($.extend(self.defaultUpState, $.gallery.currentPosition()));
        self.sprite.animate($.extend({}, self.defaultDownState, item.position()), self.zoomDuration, onZoom);
      },
      interrupt: function () {
        self.sprite.stop(true, false);
      },
      show: function () {
        self.sprite.show();
      },
      hide: function () {
        self.sprite.hide();
      }
    });
  }


  function GalleryItem(a) {   
    var self = this;
    var link = $(a);
    $.extend(self, {
      link: link,
      thumb: link.find('img'),
      image: $('<img class="preloader" />').css({visibility: 'hidden'}).appendTo($('body')),
      caption: link.next('.caption'),
      src: link.attr('href'),
      deactivate: function (event) {
        self.thumb.fadeTo('slow', 0.3);
        self.thumb.css('cursor', 'text');
        self.image.bind("load", self.activate);
        self.image.attr('src', self.src);
      },
      activate: function () {
        self.thumb.fadeTo('slow', 1);
        self.thumb.css('cursor', 'pointer');
        self.link.click(function (e) {
          if (e) {
            e.preventDefault();
            e.stopPropagation();
          }
          $.gallery.display(self);
        });
      },
      position: function () {
        var p = self.thumb.offset();
        return {
          left: p.left,
          top: p.top,
          width: self.thumb.outerWidth(),
          height: self.thumb.outerHeight()
        };
      },
      imageSize: function () {
        return {
          width: self.image.innerWidth(),
          height: self.image.innerHeight()
        };
      },
      download_url: function () {
        return self.link.attr('rel');
      }
    });
    if (!self.image.complete) {
      self.deactivate();
    } else {
      self.activate();
    }
  }

  $.fn.galleried = function() { 
    this.each(function() {
      if (!$.gallery) $.gallery = new Gallery();
      $.gallery.add(this);
    });
  };

})(jQuery);

$(function() {
  $("a.thumbnail").galleried();
});
