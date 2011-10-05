/*
  Sample jquery-based forum and gallery scripts.
  
  * inline editing of posts by authors and administrators.
  * attachment and upload of files.
  * simple show and hide for first post
  * toolbar hookup
  * submit-button protection
*/

(function($) { 

  $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;

  /* 
   * Some easing functions borrowed from the effects library to save loading the whole lot.
   * Glide is really quartic out. Boing is back out.
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

  // Edit in place for forum posts

  function RemoteAction (url, holder) {
    var self = this;
    $.extend(self, {
      url: url,
      holder: holder,
      container: null,
      form: null,

      fetch: function () {
        if (self.showing()) self.hide();
        else if (self.form) self.show();
        else {
          self.wait();
          $.get(self.url, self.step, 'html');  
        }
      },
      
      submit: function (e) {
        var ajaxable = true;
        // file to upload means not ajaxable at all
        self.container.find('input:file').each(function () {
          var file = $(this).val();
          if (file && file != "") ajaxable = false;
        });
        // presence of title field means not ajaxable because that appears elsewhere on the page
        if (self.container.find('input.titular').length > 0) ajaxable = false;

        if (ajaxable) {
          e.preventDefault();
          var editor = $(this).data('editor');
          self.form.find('textarea').each(function (box) {
            var editor = $(box).data('editor');
            if (editor) editor.save();
          });
          $.post(self.form.attr('action'), self.form.serialize(), self.step, 'html');  
        } else {
          return true;  // allow event through so that form is sent by normal HTTP POST
                        // toolbar is read in onSubmit
        }
      },
      step: function (results) {
        self.unwait();
        if (results) self.container.html(results);
        self.container.find('.cancel').click(self.cancel);
        self.form = self.container.find('form');
        if (self.form.length > 0) {
          // intermediate step: hook up the new form
          self.form.submit(self.submit);
          self.form.init_forum();
          self.show();
        } else {
          // final step: complete replacement with outcome
          $(results).init_forum();
          holder.replaceWith(results);
        }
      },
      cancel: function (event) {
        if (event) event.preventDefault();
        self.unwait();
        self.hide();
      },
      show: function () {
        self.unwait();
        self.holder.hide();
        self.container.show();
      },
      hide: function () {
        self.container.hide();
        self.holder.show();
      },
      showing: function () {
        return self.container.is(':visible');
      },
      wait: function () {
        holder.wait();
      },
      unwait: function () {
        holder.unwait();
      }
    });
    self.container = $('<div class="remote_form" />').hide();
    self.holder.append(self.container);
  }
  
  function ActionHolder(container, conf) {   
    var self = this;
    $.extend(self, {
      container: container,
      wrapper: container.find('.wrapper'),
      actions: {},
      initActions: function () {
        self.actions = {};
        self.container.find('a.remote').each(function () {
          var a = $(this);
          var href = a.attr('href');
          self.addAction(href);
          a.click(function (event) {
            if (event) event.preventDefault();
            a.addClass('waiting');
            self.showAction(href);
          });
          if (a.is('.autoload')) self.showAction(href);
        });
      },
      addAction: function (url) {
        if (!self.actions[url]) self.actions[url] = new RemoteAction(url, self);
        return self.actions[url];
      },
      showAction: function (url) {
        $.each(self.actions, function (key, action) { action.hide(); });
        self.actions[url].fetch();
      },
      append: function (el) {
        return self.container.append(el);
      },
      replaceWith: function (html) {
        self.container.html(html);
        self.wrapper = self.container.find('.wrapper');
        self.initActions();
        return self.container;
      },
      show: function () {
        self.wrapper.show();
      },
      hide: function () {
        self.wrapper.hide();
      },
      toggle: function (event) {
        if (event) event.preventDefault();
        if (self.wrapper.is(":visible")) self.hide();
        else self.show();
      },
      wait: function () {
        self.container.addClass('waiting');
        self.container.find('a.remote').addClass('waiting');
      },
      unwait: function () {
        self.container.removeClass('waiting');
        self.container.find('a.remote').removeClass('waiting');
      }
    });
    self.initActions();
  }
  
  $.fn.enable_remote_actions = function(conf) {
    this.each(function() {
      new ActionHolder($(this), conf);
    });
    return this;
  };

  // First post on pages after 1 is hidden but can be revealed for reference

  function HideablePost(container, conf) {   
    var self = this;
    $.extend(self, {
      head: container.find('.post_header'),
      body: container.find('.post_body'),
      shower: null,
      show: function () {
        self.body.slideDown();
        self.shower.text('Hide');
      },
      hide: function () {
        self.body.slideUp();
        self.shower.text('Show');
      },
      toggle: function (event) {
        if (event) event.preventDefault();
        if (self.body.is(":visible")) self.hide();
        else self.show();
      }
    });
    if ($('a.prev_page').length > 0) {
      self.shower = $('<a href="#" class="shower">Hide</a>').appendTo(self.head.find('p.context'));
      self.shower.click(self.toggle);
      self.hide();
    }
  }

  $.fn.hideable_post = function() { 
    this.each(function() {      
      new HideablePost($(this));
    });
    return this;
  };

  // The upload stack is a friendly attacher and uploader.
  // the edit in place functionality will check for uploads and route over normal http if any are found.

  function UploadStack(container) {   
    var self = this;
    $.extend(self, {
      container: container,
      attachments_list: container.find('ul.attachments'),
      uploads_list: container.find('ul.uploads'),
      selector: container.find('div.selector'),
      file_field: container.find('div.selector').find('input'),
      
      addUpload: function(event) {
        if (event) event.preventDefault();
        var title = self.file_field.val().replace(/C:\\fakepath\\/, '');
        var empty_field = self.file_field.clone();
        var upload_field = self.file_field;
        var nest_id = self.attachmentCount() + self.uploadCount();  // nb. starts at zero so this total is +1
        var container = $('<li class="attachment unsaved">' + title + '</li>');
        upload_field.attr("id", upload_field.attr('id').replace(/\d+/, nest_id));
        upload_field.attr("name", upload_field.attr('name').replace(/\d+/, nest_id));
        container.append(upload_field);
        container.add_remover();
        container.appendTo(self.uploads_list).slideDown('slow');
        empty_field.val(null);
        self.file_field = empty_field;
        self.selector.prepend(empty_field);
        self.selector.find('a').text = 'attach another file';
      },
      
      attachmentCount: function () {
        return self.attachments_list.find('li').length;
      },

      hasAttachments: function () {
        return self.attachments_list.find('li').length > 0;
      },
      
      uploadCount: function () {
        return self.uploads_list.find('li').length;
      },
      
      hasUploads: function () {
        return self.uploadCount() > 0;
      }
    });
    self.attachments_list.find('li').add_remover();
    self.file_field.change(self.addUpload);
  }
  
  $.fn.upload_stack = function(conf) { 
    this.each(function() {      
      el = new UploadStack($(this), conf);
    });
    return this;
  };

  $.fn.add_remover = function() { 
    this.each(function() {
      var self = $(this);
      var remover = $('<a href="#" class="remove">remove</a>');
      remover.click(function (event) { 
        if (event) event.preventDefault();
        self.slideUp('500', function() { 
          self.find('input.checkbox').attr('checked', true);
          self.find('input.filefield').remove();
        }); 
      });
      self.append(remover);
    });
    return self;
  };

  // turns the standard search box into a remote form with dropdown results list

  $.fn.capture_search = function() { 
    this.each(function() { 
      var self = $(this);
      var target = $('#results');
      if (target.length >= 1) {
        self.submit(function (e) {
          if(e) e.preventDefault();
          self.addClass("waiting");
          target.addClass("waiting");
          target.load(self.attr('action'), self.serialize(), function () { 
            self.removeClass("waiting"); 
            target.removeClass("waiting");
          });  
        });
      } else {
        return true;
      }
    });
    return this;
  };
  
  // adds a cleditor toolbar to a textarea
  
  $.fn.add_rte = function() { 
    this.cleditor({
      width: 630,
      height: 400,
      controls: "bold italic underline strikethrough size removeformat | bullets numbering outdent indent | icon link unlink | source"
    });
  };
  
  // initializes forum functionality in any block of html
  // including, initially, the document.

  $.fn.init_forum = function () {
    this.each(function() { 
      var self = $(this);
      self.find(".post").enable_remote_actions();
      self.find(".new_post").enable_remote_actions();
      self.find(".post.first").hideable_post();
      self.find(".upload_stack").upload_stack();
      self.find(".forum_search").capture_search();
      self.find("textarea.rte").add_rte();
    });
    return this;
  };
})(jQuery);

$(function() {
  $(document).init_forum();
  
  $("input:submit").live('click', function (event) {
    var self = $(this);
    self.after('<span class="waiting">Please wait</span>');
    self.hide();
    return true;
  });
});
