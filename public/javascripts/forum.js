/*
  Sample jquery-based forum scripts.
  
  * inline editing of posts by authors and administrators.
  * attachment and upload of files.
  * simple show and hide for first post
  * toolbar hookup
  * submit-button protection
*/

(function($) { 

  $.ajaxSetup({
    'beforeSend': function(xhr) {
      xhr.setRequestHeader("Accept", "text/javascript");
    }
  });
  
  // general-purpose event blocker
  function squash(e) {
    if(e) {
      e.preventDefault();
      e.stopPropagation();
      if (e.target) e.target.blur();
    } 
  }
  
  function RemoteAction (url, holder) {
    var self = this;
		$.extend(self, {
		  url: url,
		  holder: holder,
		  container: null,
		  form: null,

		  getForm: function () {
		    if (self.showing()) self.hide();
        else if (self.form) self.show();
        else {
          self.wait();
          self.container.load(self.url, self.captureForm);
        }
      },
      captureForm: function () {
        self.form = self.container.find('form');
        self.form.submit(self.submitForm);
        self.form.find('div.upload_stack').upload_stack();
        self.form.find('a.cancel').click(self.cancel);
        self.form.find("textarea.toolbarred").add_editor({});
        
        self.unwait();
        self.show();
      },
      submitForm: function (event) {
        var ajaxable = true;
        self.container.find('input:file').each(function () {
          var file = $(this).val();
          if (file && file != "") ajaxable = false;
        });
        if (ajaxable) {
          squash(event);
          self.form.find('textarea.toolbarred').read_editor();
          $.post(self.form.attr('action'), self.form.serialize(), self.finish);  
        } else {
          return true;  // allow event through so that uploads are sent by normal HTTP POST
        }
      },
      cancel: function (event) {
        squash(event);
        self.unwait();
        self.hide();
      },
      finish: function (results) {
        self.unwait();
        var newpost = holder.replaceWith(results);
        newpost.blush();
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
		
		self.container = $('<div class="post_form" />').hide();
		self.holder.append(self.container);
  }
  
  
	function EditablePost(container, conf) {   
    var self = this;
		$.extend(self, {
		  container: container,
		  wrapper: container.find('.post_wrapper'),
		  head: container.find('.post_header'),
		  body: container.find('.post_body'),
		  actions: {},
      addAction: function (url) {
        if (!self.actions[url]) self.actions[url] = new RemoteAction(url, self);
        return self.actions[url];
      },
      showAction: function (url) {
        $.each(self.actions, function (key, action) { action.hide(); });
        self.actions[url].getForm();
      },
      append: function (el) {
        return self.wrapper.append(el);
      },
      replaceWith: function (post) {
        self.container.replaceWith(post);
        return $(post).editable_post();
      },
      show: function () {
        self.body.show();
      },
      hide: function () {
        self.body.hide();
      },
      toggle: function (event) {
        squash(event);
        if (self.body.is(":visible")) self.hide();
        else self.show();
      },
      wait: function () {
        self.container.addClass('waiting');
      },
      unwait: function () {
        self.container.removeClass('waiting');
        self.container.find('a').removeClass('waiting');
      }
		});
		
		container.find('a.remote').each(function () {
		  var a = $(this);
		  var href = a.attr('href');
      self.addAction(href);
      a.click(function (event) {
        squash(event);
        a.addClass('waiting');
        self.showAction(href);
      });
		});
	}
	
	$.fn.editable_post = function(conf) { 
		this.each(function() {			
			new EditablePost($(this), conf);
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
        squash(event);
        if (self.body.is(":visible")) self.hide();
        else self.show();
      }
		});

	  self.shower = $('<a href="#" class="shower">Hide</a>').appendTo(self.head.find('p.context'));
    self.shower.click(self.toggle);
    if ($('a.prev_page').length > 0) self.hide();
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
        squash(event);
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
        squash(event);
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
		return this;
	};

	$.fn.read_editor = function() { 
		this.each(function() { 
		  var self = $(this);
		  if (self.data('editor')) {
		    self.val(self.data('editor').getContent());
		  }
		});
		return this;
	};
	
  /*
   * jQuery Color Animations
   * Copyright 2007 John Resig
   * Released under the MIT and GPL licenses.
   * syntax corrected but otherwise untouched.
   */
  
  // We override the animation for all of these color styles
  $.each(['backgroundColor', 'borderBottomColor', 'borderLeftColor', 'borderRightColor', 'borderTopColor', 'color', 'outlineColor'], function(i, attr) {
    $.fx.step[attr] = function(fx) {
      if (!fx.colorInit) {
        fx.start = getColor(fx.elem, attr);
        fx.end = getRGB(fx.end);
        fx.colorInit = true;
      }

      fx.elem.style[attr] = "rgb(" + [
      Math.max(Math.min(parseInt((fx.pos * (fx.end[0] - fx.start[0])) + fx.start[0], 10), 255), 0),
      Math.max(Math.min(parseInt((fx.pos * (fx.end[1] - fx.start[1])) + fx.start[1], 10), 255), 0),
      Math.max(Math.min(parseInt((fx.pos * (fx.end[2] - fx.start[2])) + fx.start[2], 10), 255), 0)
      ].join(",") + ")";
    }
  });

  // Color Conversion functions from highlightFade
  // By Blair Mitchelmore
  // http://jquery.offput.ca/highlightFade/

  // Parse strings looking for color tuples [255,255,255]
  function getRGB(color) {
      var result;

      // Check if we're already dealing with an array of colors
      if ( color && color.constructor == Array && color.length == 3 )
          return color;

      // Look for rgb(num,num,num)
      if (result = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(color))
          return [parseInt(result[1], 10), parseInt(result[2], 10), parseInt(result[3], 10)];

      // Look for rgb(num%,num%,num%)
      if (result = /rgb\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*\)/.exec(color))
          return [parseFloat(result[1])*2.55, parseFloat(result[2])*2.55, parseFloat(result[3])*2.55];

      // Look for #a0b1c2
      if (result = /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(color))
          return [parseInt(result[1],16), parseInt(result[2],16), parseInt(result[3],16)];

      // Look for #fff
      if (result = /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/.exec(color))
          return [parseInt(result[1]+result[1],16), parseInt(result[2]+result[2],16), parseInt(result[3]+result[3],16)];

      // Look for rgba(0, 0, 0, 0) == transparent in Safari 3
      if (result = /rgba\(0, 0, 0, 0\)/.exec(color))
          return colors['transparent'];

      // Otherwise, we're most likely dealing with a named color
      return colors[jQuery.trim(color).toLowerCase()];
  }

  function getColor(elem, attr) {
    var color;

    do {
      color = $.curCSS(elem, attr);

      // Keep going until we find an element that has color, or we hit the body
      if ( color != '' && color != 'transparent' || jQuery.nodeName(elem, "body") )
        break;

      attr = "backgroundColor";
    } while ( elem = elem.parentNode );

    return getRGB(color);
  };

  // Some named colors to work with
  // From Interface by Stefan Petre
  // http://interface.eyecon.ro/

  var colors = {
      aqua:[0,255,255],
      azure:[240,255,255],
      beige:[245,245,220],
      black:[0,0,0],
      blue:[0,0,255],
      brown:[165,42,42],
      cyan:[0,255,255],
      darkblue:[0,0,139],
      darkcyan:[0,139,139],
      darkgrey:[169,169,169],
      darkgreen:[0,100,0],
      darkkhaki:[189,183,107],
      darkmagenta:[139,0,139],
      darkolivegreen:[85,107,47],
      darkorange:[255,140,0],
      darkorchid:[153,50,204],
      darkred:[139,0,0],
      darksalmon:[233,150,122],
      darkviolet:[148,0,211],
      fuchsia:[255,0,255],
      gold:[255,215,0],
      green:[0,128,0],
      indigo:[75,0,130],
      khaki:[240,230,140],
      lightblue:[173,216,230],
      lightcyan:[224,255,255],
      lightgreen:[144,238,144],
      lightgrey:[211,211,211],
      lightpink:[255,182,193],
      lightyellow:[255,255,224],
      lime:[0,255,0],
      magenta:[255,0,255],
      maroon:[128,0,0],
      navy:[0,0,128],
      olive:[128,128,0],
      orange:[255,165,0],
      pink:[255,192,203],
      purple:[128,0,128],
      violet:[128,0,128],
      red:[255,0,0],
      silver:[192,192,192],
      white:[255,255,255],
      yellow:[255,255,0],
      transparent: [255,255,255]
  };

  $.fn.blush = function(color, duration) {
    color = color || "#FFFF9C";
    duration = duration || 1500;
    var backto = this.css("background-color");
    if (backto == "" || backto == 'transparent') backto = '#ffffff';
    this.css("background-color", color).animate({"background-color": backto}, duration);
  };
  

})(jQuery);

$(function() {
  $(".post").editable_post({});
  $(".post.first").hideable_post({});
  $(".upload_stack").upload_stack({});
  $(".toolbarred").add_editor({});
  $("input:submit").live('click', function (event) {
	  var self = $(this);
    self.after('<span class="waiting">Please wait</span>');
    self.hide();
    return true;
  });
});
