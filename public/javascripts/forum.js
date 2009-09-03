window.addEvent('domready', function(){
  getPosts();
  flashErrors();
  fadeNotices();
});

Element.implement({
  dwindle: function () {
    this.morph({opacity: 0, height: 0});
  }
});

var block = function (e) {
	if (e) {
		if (e.target) e.target.blur();
		e = new Event(e);
		e.preventDefault();
		e.stop;
		return e;
	}
};

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

replaceWithDestination = function (element) {
  element.addClass('waiting');
  var formholder = element.getParent();
  formholder.load(element.get('href'));
};

getPosts = function () {
  $$('div.post').each(function (div) { new Post(div); });
  $$('div.upload_handler').each(function (div) { new UploadHandler(div); });
};

// post machinery: editable, deletable and soon flaggable in place

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
    if (url) this.formHolder().load(url);
  },
  
  formHolder: function () {
    if (this.form_holder) return this.form_holder;
    this.form_holder = new Element('div', {'class': 'post_form'});
    this.form_holder.set('load', {onComplete: this.prepForm.bind(this)});
    return this.form_holder;
  },
  
  prepForm: function () {
    this.form_holder.inject(this.wrapper, 'top');
    this.body_holder.hide();
    this.editor.removeClass('waiting');
    this.form = this.form_holder.getElement('form');
    this.input = this.form.getElement('textarea');
    this.input.setStyle('height', this.h);
    this.form_holder.getElement('a.cancel').addEvent('click', this.cancel.bindWithEvent(this));
    this.uploader = new UploadHandler(this.form_holder.getElement('div.upload_handler'));
    this.stumbit = this.form_holder.getElement('div.buttons');
    this.form.onsubmit = this.sendForm.bind(this);
    // new Fx.Morph(this.input, {duration: 'short'}).start({'height' : 240, opacity : 1});
    this.form_holder.show();
    this.showing = true;
  },
  
  sendForm: function (e) {
    var waiter = new Element('p', {'class' : 'waiting'}).set('text', 'please wait');
    waiter.replaces(this.stumbit);

    if (this.uploader && this.uploader.hasUploads()) {
      // can't send uploads over xmlhttp so we allow the form to submit
      // the update-post action will redirect to a hashed url that should return us to the right post
    } else {
      block(e);
      new Request.HTML({
        url: this.form.get('action'),
        update: this.container,
        onComplete: this.finishEdit.bind(this)
      }).post(this.form);
    }
    
  },
  cancel: function (e) {
    block(e);
    this.finishCancel();
    // new Fx.Morph(this.input, {duration: 'short', onComplete : this.finishCancel.bind(this)}).start({'height' : this.h, opacity : 0});
  },
  finishCancel: function () {
    this.form_holder.hide();
    this.body_holder.show();
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
    this.shower = div.getElement('a');
    this.list = div.getElement('ul.attachments');
    this.pender = div.getElement('div.uploads');
    this.selector = div.getElement('div.selector');

    this.file_field_template = this.selector.getElement('input').clone();
    this.file_pending_template = new Element('li');

    this.attachments = [];
    this.list.getElements('lattachment').each(function (li) {
      this.attachments.push( new Attachment(li));
    }, this);

    this.uploads = [];
    this.uploader = this.selector.getElement('input');
    this.uploader.addEvent('change', this.addUpload.bindWithEvent(this));

    this.reveal = new Fx.Slide(div.getElement('div.attachments'));
    this.shower.addEvent('click', this.toggle.bindWithEvent(this));

    if (!this.hasAttachments()) this.reveal.hide();
  },
  toggle: function (e) {
    block(e);
    this.reveal.toggle();
  },
  addUpload: function (e) {
    block(e);
    this.uploads.push(new Upload(this));
    this.resize();
  },
  pendUpload: function (argument) {
    var ul = this.uploader.clone().inject(this.pender);
    this.uploader.set('value', null);
    return ul;
  },
  hasAttachments: function () {
    return this.attachments.length != 0;
  },
  hasUploads: function () {
    return this.uploads.length != 0;
  },
  resize: function () {
    this.reveal.slideIn();
  }
});

var Upload = new Class({
  initialize: function (handler) {
    this.handler = handler;
    this.uploader = this.handler.pendUpload();
    this.container = new Element('li', {'class': 'attachment'}).set('text', ' ' + this.uploader.value + ' ');
    this.icon = new Element('img').set('src', this.icon_for(this.uploader.value)).inject(this.container, 'top');
    this.remover = new Element('a', {'class': 'remove', 'href': '#'}).set('text', 'remove').inject(this.container, 'bottom');
    this.remover.addEvent('click', this.remove.bindWithEvent(this));
    this.container.inject(this.handler.list, 'bottom');
  },
  icon_for: function (filename) {
    return '/images/forum/icons/attachment_new.png';
  },
  remove: function (e) {
    block(e);
    this.uploader.destroy();
    this.container.nix();
    this.handler.resize();
  }
});

var Attachment = new Class({
  initialize: function (li) {
    this.container = li;
    this.checkbox = lgetElement('input.choose_attachment');
    this.remover = lgetElement('a.remove');
    this.remover.addEvent('click', this.remove.bindWithEvent(this));
  },
  remove: function (e) {
    block(e);
    if (this.checkbox) this.checkbox.set('checked', false);
    this.container.nix();
  },
  hide: function () {
    this.container.hide();
  }
});










