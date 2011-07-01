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
        if (self.container.find('input:text').length > 0) ajaxable = false;

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
          self.form.submit(self.submit);
          self.form.init_forum();
          self.show();
        } else {
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
        var upload_field = self.file_field.clone();
        var nest_id = self.attachmentCount() + self.uploadCount();  // nb. starts at zero so this total is +1
        var container = $('<li class="attachment">' + upload_field.val() + '</li>');
        upload_field.attr("id", upload_field.attr('id').replace(/\d+/, nest_id));
        upload_field.attr("name", upload_field.attr('name').replace(/\d+/, nest_id));
        container.append(upload_field);
        container.add_remover();
        container.appendTo(self.uploads_list).slideDown('slow');
        self.file_field.val(null);
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

  $.fn.add_editor = function() { 
    if(window.punymce !== undefined) {
      this.each(function() {
        var self = $(this);
        var editor = new punymce.Editor({
          id : self.attr('id'),
          plugins : 'Link,Image,Emoticons,EditSource',
          toolbar : 'bold,italic,link,unlink,image,emoticons,editsource',
          width : 510,
          height : 375,
          resize : true
        });
        self.data('editor', editor);
      });
    }
    return this;
  };

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
  
  $.fn.add_rte = function() { 
    this.cleditor({
      width: 630,
      height: 400,
      controls: "bold italic underline strikethrough size removeformat | bullets numbering outdent indent | icon image link unlink | source"
    });
  };
  
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
