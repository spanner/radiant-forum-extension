/*
  Sample jquery-based forum scripts.
  
  Two functions are handled here: 
  * inline editing of posts by authors and administrators.
  * attachment and upload of files.
*/

(function($) { 

  $.ajaxSetup({
    'beforeSend': function(xhr) {
      xhr.setRequestHeader("Accept", "text/javascript");
    }
  });
  
	function EditablePost(container, conf) {   
    var self = this;
		$.extend(self, {
		  container: container,
      edit_links: $(container.find('a.edit_post')),
      edit_url: null,
      form: null,
			stumbit: null,
			textarea: null,
      showing: false,
			header: null,
      wrapper: null,
      body_holder: null,
      form_holder: null,
      form_waiter: null,
      uploader: null,
      
			initEdit: function(event) {
			  squash(event);
        self.edit_links.addClass('waiting');
        if (self.showing) self.cancelEdit();            // toggle form off again
        else if (self.form_holder) self.showForm();     // show previously-loaded form
        else {                                          // load form
          self.header = $(container.find('.post_header'));
          self.wrapper = $(container.find('.post_wrapper'));
          self.body_holder = $(container.find('.post_body'));
          self.edit_links = $(container.find('a.edit_post'));
          self.getForm();
        } 
			},
			
			getForm: function () {
        if (self.edit_url) self.reusableFormHolder().load(self.edit_url, self.captureForm);
      },
      
      // lazy-load a container div that is then held in memory instead of 
      // going back to the server for another edit form
      reusableFormHolder: function () {
        if (self.form_holder) return self.form_holder;
        self.form_holder = $('<div class="post_form" />');
        self.wrapper.prepend(self.form_holder);
        return self.form_holder;
      },

			captureForm: function () {
        self.form = self.form_holder.find('form');
        self.textarea = self.form.find('textarea');
        self.form_holder.find('a.cancel').click(self.cancelEdit);
        self.uploader = new UploadStack(self.form_holder.find('div.upload_stack'));
        self.stumbit = self.form_holder.find('div.buttons');
        self.form.submit(self.sendForm);
        self.showForm();
      },
            
      showForm: function () {
        self.edit_links.removeClass('waiting');
        self.body_holder.hide();
        self.reusableFormHolder().show();
        self.showing = true;
      },
      
      hideForm: function () {
        self.reusableFormHolder().hide();
        self.body_holder.show();
        self.showing = false;
      },

      sendForm: function (event) {
        self.form_waiter = $('<p class="waiting">Please wait</p>');
        self.stumbit.hide();
        self.form_waiter.after(self.stumbit);
        
        console.log("uploader:", self.uploader, self.uploader.hasUploads());
        
        if (self.uploader && self.uploader.hasUploads()) {
          console.log("yes uploads");
          return true;  // can't send uploads over xmlhttp so we allow the event to pass through
        } else {
          console.log("no uploads");
          squash(event);
          $.post(self.form.attr('action'), self.form.serialize(), self.finishEdit);
        }
      },

      cancelEdit: function (event) {
        squash(event);
        self.edit_links.removeClass('waiting');
        self.hideForm();
      },
      
      finishEdit: function (results) {
        self.form_holder.remove();
        self.form_holder = null;
        self.container.html(results);
        self.body_holder.animate( { backgroundColor: 'pink' }, 200).animate( { backgroundColor: 'white' }, 1000);
        self.container.editable_post();
      }
		});

    self.edit_url = self.edit_links.attr('href');
    self.edit_links.click(self.initEdit);
	}
	
	$.tools.post = {
		conf: {	

		}
	};
	
	$.fn.editable_post = function(conf) { 
		conf = $.extend({}, $.tools.post.conf, conf); 
		this.each(function() {			
			el = new EditablePost($(this), conf);
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
        var container = $('<li class="attachment">' + upload_field.val() + '</li>');
        container.append(upload_field);
        container.add_remover();
        container.appendTo(self.uploads_list).slideDown('slow');
        self.file_field.val(null);
        self.selector.find('a').text = 'attach another file';
      },
      
      hasAttachments: function () {
        return self.attachments_list.find('li').length > 0;
      },
      
      hasUploads: function () {
        return self.uploads_list.find('li').length > 0;
      }
    });
    self.attachments_list.find('li').add_remover();
    self.file_field.change(self.addUpload);
	}

	$.tools.stack = {
		conf: {	

		}
	};
	
	$.fn.upload_stack = function(conf) { 
		conf = $.extend({}, $.tools.stack.conf, conf); 
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
        self.slideUp('500', function() { self.remove(); }); 
      });
      self.append(remover);
	  });
		return self;
	};

})(jQuery);

$(function() {
  $(".post").editable_post({});
  $(".upload_stack").upload_stack({});
});
