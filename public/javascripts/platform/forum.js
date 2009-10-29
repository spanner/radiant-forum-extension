var Post = new Class({
  initialize: function (div) {
    this.container = div;
    this.header = div.getElement('div.post_header');
    this.wrapper = div.getElement('div.post_wrapper');
    this.body_holder = div.getElement('div.post_body');
    this.h = this.body_holder.getHeight();
    this.editors = this.container.getElements('a.edit_post');
    this.editors.each(function (a) {
      a.addEvent('click', this.edit.bindWithEvent(this));
    }, this);
    this.showing = false;
    this.form_holder = null;
    this.form = null;
  },
  
  edit: function(e){
    unevent(e);
    var link = e.target;
    link.addClass('waiting');
    if (this.showing) this.cancel();
    else if (this.form_holder) this.prepForm();
    else this.getForm(link.get('href'));
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
    this.editors.removeClass('waiting');
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
      unevent(e);
      new Request.HTML({
        url: this.form.get('action'),
        update: this.container,
        onComplete: this.finishEdit.bind(this)
      }).post(this.form);
    }
    
  },
  cancel: function (e) {
    unevent(e);
    this.finishCancel();
    // new Fx.Morph(this.input, {duration: 'short', onComplete : this.finishCancel.bind(this)}).start({'height' : this.h, opacity : 0});
  },
  finishCancel: function () {
    this.form_holder.hide();
    this.body_holder.show();
    this.editors.removeClass('waiting');
    this.showing = false;
  },
  finishEdit: function () {
    this.container.highlight();
    new Post(this.container);
  }
});

var uh = null;
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
    this.list.getElements('li.attachment').each(function (li) { this.attachments.push( new Attachment(li)); }, this);

    this.uploads = [];
    this.uploader = this.selector.getElement('input');
    this.uploader.addEvent('change', this.addUpload.bindWithEvent(this));
    this.fakelink = this.selector.getElement('a');
    
    // this.reveal.hide();
    uh = this;
  },
  addUpload: function (e) {
    unevent(e);
    this.uploads.push(new Upload(this));
    this.fakelink.set('text', 'attach another file');
  },
  pendUpload: function (argument) {
    var ul = this.uploader.inject(this.pender);
    this.uploader = ul.clone().inject(this.selector);
    this.uploader.set('value', null);
    this.uploader.addEvent('change', this.addUpload.bindWithEvent(this));
    return ul;
  },
  hasAttachments: function () {
    return this.attachments.length > 0;
  },
  hasUploads: function () {
    return this.uploads.length > 0;
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
    this.container.set('morph', {duration : 'long'});
    this.container.reveal();
  },
  icon_for: function (filename) {
    return '/images/forum/attachment.png';
  },
  remove: function (e) {
    unevent(e);
    this.uploader.destroy();
    this.container.nix();
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
    unevent(e);
    if (this.checkbox) this.checkbox.set('checked', false);
    this.container.nix();
  },
  hide: function () {
    this.container.hide();
  }
});





activations.push(function (scope) {
  scope.getElements('div.post').each(function (div) { new Post(div); });
  scope.getElements('div.upload_handler').each(function (div) { new UploadHandler(div); });  
});
