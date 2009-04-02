window.addEvent('domready', function(){
  // getPosts();
  // getRemoteCheckboxes();
  getUploadHandler();
  flashErrors();
  fadeNotices();
});

Element.implement({
  dwindle: function () {
    this.morph({opacity: 0, height: 0});
  }
});
  
// get rid of radiant notifications (after a pause)

fadeNotices = function () {
  reallyFadeNotices.delay(2000);
}

reallyFadeNotices = function () {
  $$('div#notice').fade('out');
  $$('div#error').fade('out');
}

// flash validation errors

flashErrors = function () {
  $$('p.with_errors').each(function (element) { element.highlight(); });
}

// flash #destination

flashAnchor = function () {
  var hash = window.location.hash;
  if (hash && $(hash)) $(hash).highlight();
};

// turns a link into a form
// so that eg a reply link becomes a reply form or a login form as required
// this allows us to return a cached page but display suitable interaction
// which does slightly defeat the object, but keeps the server side clean

getForms = function () {
  document.getElements('a.retrieve_form').each(function (a) { replaceWithDestination(a); });
};

// these are usually topic-monitoring forms

getRemoteCheckboxes = function () {
  document.getElements('input.monitor_submit').each(function (element) { element.hide(); });
	FancyForm.start( 
	  document.getElements('input.remote_checkbox'), {
  	onSelect: function(chk){ remoteCheckBox(chk); },
  	onDeselect: function(chk){ remoteCheckBox(chk); }
  });
};

remoteCheckBox = function (chk) {
  if (chk.form) {
    var methodfield = form.getElement('#_method');
    if (methodfield) methodfield.value = chk.hasClass('checked') ? '' : 'delete';
    var req = new Request.JSON({
      url: form.get('action'),
      onRequest: function () { chk.addClass('waiting'); },
      onSuccess: function (response) { chk.removeClass('waiting'); chk.highlight(); },
      onFailure: function (response) { chk.removeClass('waiting'); chk.addClass('error'); }
    }).post(form);
  }
};

replaceWithDestination = function (element) {
  element.addClass('waiting');
  var formholder = element.getParent();
  formholder.load(element.get('href'));
};

getUploadHandler = function () {
  document.getElements('div.upload_handler').each(function (div) { new UploadHandler(div); });
};

// thoroughly interfere with javascript events

var block = function (e) {
	if (e) {
		if (e.target) e.target.blur();
		e = new Event(e);
		e.preventDefault();
		e.stop;
		return e;
	}
};

// initialize the post machinery: editable, deletable and flaggable in place

getPosts = function () {
  $$('div.post').each(function (div) { new Post(div); });
};

var Post = new Class({
  initialize: function (div) {
    this.container = div;
    this.header = div.getElement('div.post_header');
    this.wrapper = div.getElement('div.post_wrapper');
    this.body_holder = div.getElement('div.post_body');
    this.h = this.body_holder.getHeight();
    this.editor = div.getElement('a.edit_post');
    if (this.editor) {
      this.editor.addEvent('click', this.edit.bindWithEvent(this));
      this.body_holder.addEvent('dblclick', this.edit.bindWithEvent(this));
    }
    this.showing = false;
    this.form_holder = null;
    this.form = null;
  },
  
  edit: function(e){
    block(e);
    this.editor.addClass('waiting');
    if (this.showing) this.cancel();
    else if (this.form_holder) this.prepForm();
    else this.getForm(this.editor.get('href'));
  },
  
  getForm: function (url) {
    console.log('getform');
    if (url) this.formHolder().load(url);
  },
  
  prepForm: function () {
    this.body_holder.fade('hide');
    this.form_holder.fade('in');
    this.editor.removeClass('waiting');
    this.form = this.formHolder().getElement('form');
    this.input = this.form.getElement('textarea');
    this.input.setStyle('height', this.h - 40);
    this.formHolder().getElement('a.cancel').addEvent('click', this.cancel.bindWithEvent(this));
		this.form.onsubmit = this.sendForm.bind(this);
    this.showing = true;
  },
  
  sendForm: function (e) {
    block(e);
    var finish_edit = this.finishEdit.bind(this);
    var req = new Request.HTML({
      url: this.form.get('action'),
      update: this.container,
      onComplete: finish_edit
    }).post(this.form);
  },
  
  formHolder: function () {
    if (this.form_holder) return this.form_holder;
    this.form_holder = new Element('div', {'class': 'post_form'});
    this.form_holder.set('load', {onComplete: this.prepForm.bind(this)});
    this.form_holder.setStyle('height', this.h);
    this.form_holder.fade('hide');
    this.form_holder.inject(this.wrapper, 'top');
    return this.form_holder;
  },
  
  cancel: function (e) {
    block(e);
    this.form_holder.fade('hide');
    this.body_holder.fade('in');
    this.editor.removeClass('waiting');
    this.showing = false;
  },
  
  finishEdit: function () {
    this.container.highlight();
    new Post(this.container);
  }  
});

var UploadHandler = new Class({
  initialize: function (div) {
    this.container = div;
    this.list = div.getElement('ul.attachments');
    this.pender = div.getElement('div.uploads');
    this.selector = div.getElement('div.selector');

    this.file_field_template = this.selector.getElement('input').clone();
    this.file_pending_template = new Element('li');

    this.attachments = [];
    this.list.getElements('li.attachment').each(function (li) {
      this.attachments.push( new Attachment(li));
    }, this);

    this.uploads = [];
    this.uploader = this.selector.getElement('input');
    this.uploader.addEvent('change', this.addUpload.bindWithEvent(this));
  },
  addUpload: function (e) {
    block(e);
    this.uploads.push(new Upload(this.uploader, this.pender, this.list));
    this.uploader.set('value', null);
  }
});

var Upload = new Class({
  initialize: function (file_input, ul_holder, list_div) {
    this.uploader = file_input.clone().set('id', 'test').inject(ul_holder);
    this.container = new Element('li', {'class': 'attachment'}).set('text', ' ' + this.uploader.value + ' ');
    this.icon = new Element('img').set('src', this.icon_for(this.uploader.value)).inject(this.container, 'top');
    this.remover = new Element('a', {'class': 'remove', 'href': '#'}).set('text', 'remove').inject(this.container, 'bottom');
    this.remover.addEvent('click', this.remove.bindWithEvent(this));
    this.container.inject(list_div, 'bottom');
  },
  icon_for: function (filename) {
    switch(filename.split('.').pop()) {
      case 'pdf': return '/images/icons/24/pdf.png';
      case 'mpg': return '/images/icons/24/video.png';
      case 'mp3': return '/images/icons/24/audio.png';
      default: return '/images/icons/24/image.png';
    }
  },
  remove: function (e) {
    block(e);
    this.uploader.destroy();
    this.container.dwindle();
  }
});

var Attachment = new Class({
  initialize: function (li) {
    this.container = li;
    this.checkbox = li.getElement('input.choose_attachment');
    this.remover = li.getElement('a.remove');
    this.remover.addEvent('click', this.remove.bindWithEvent(this));
  },
  remove: function (e) {
    block(e);
    if (this.checkbox) this.checkbox.set('checked', false);
    this.container.dwindle();
  },
  hide: function () {
    this.container.hide();
  }
});









