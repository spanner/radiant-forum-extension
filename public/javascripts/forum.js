Element.implement({
	isVisible: function() {
		return this.getStyle('display') != 'none';
	},
	toggle: function() {
		return this[this.isVisible() ? 'hide' : 'show']();
	},
	hide: function() {
		this.originalDisplay = this.getStyle('display'); 
		this.setStyle('display','none');
		return this;
	},
	show: function(display) {
		this.originalDisplay = (this.originalDisplay=="none")?'block':this.originalDisplay;
		this.setStyle('display', (display || this.originalDisplay || 'block'));
		return this;
	},
  dwindle: function () {
    var element = this;
    new Fx.Morph(element, {
  		duration: 600,
  		onComplete: function () { element.remove(); }
  	}).start({ 
  	  'opacity': 0,
  	  'width': 0,
  	  'height': 0
  	});
  }
});

String.implement({
  endsWith: function(pattern) {
    var d = this.length - pattern.length;
    return d >= 0 && this.lastIndexOf(pattern) === d;
  }
});

var f = null;
window.addEvent('domready', function(){
  f = new Forum();
});

var Forum = new Class({
	initialize: function(){
	  this.posts = [];
    this.getPosts();
    this.getRemoteCheckboxes();
    this.getForms();
    this.flashErrors();
    this.fadeNotices();
  },
  
  // get rid of radiant notifications (after a pause)
  
  fadeNotices: function () {
    (function () { f.reallyFadeNotices(); }).delay(2000);
  },
  reallyFadeNotices: function () {
    $$('div#notice').fade('out');
    $$('div#error').fade('out');
  },
  
  // flash validation errors
  
  flashErrors: function () {
    $$('p.with_errors').each(function (element) { element.highlight(); });
  },
  
  // flash #destination
  
  flashAnchor: function () {
    var hash = window.location.hash;
    if (hash && $(hash)) $(hash).highlight();
  },
  
  // initialize the editable-in-place
  
  getPosts: function () {
    $$('div.post').each(function (div) { this.posts.push(new Post(div)); }, this);
  },
  
  // turns a link into a form
  // so that eg a reply link becomes a reply form or a login form as required
  // this allows us to return a cached page but display suitable interaction
  
  getForms: function () {
    document.getElements('a.retrieve_form').each(function (a) { this.replaceWithDestination(a); }, this);
  },
  
  // these are usually topic-monitoring forms

  getRemoteCheckboxes: function () {
    document.getElements('input.monitor_submit').each(function (element) { element.hide(); });
  	FancyForm.start( 
  	  document.getElements('input.monitor_checkbox'), {
    	onSelect: function(chk){ f.remoteCheckBox(chk); },
    	onDeselect: function(chk){ f.remoteCheckBox(chk); }
    });
  },
  remoteCheckBox: function (chk) {
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
  },
  
  replaceWithDestination: function (element) {
    element.addClass('waiting');
    var formholder = element.getParent();
    formholder.load(element.get('href'));
  }
});


var Post = new Class({
  initialize: function (div) {
    this.container = div;
    this.header = div.getElement('div.post_header');
    this.wrapper = div.getElement('div.post_wrapper');
    this.body_holder = div.getElement('div.post_body');
    this.h = this.body_holder.getHeight();
    this.editor = div.getElement('a.edit_post');
    if (this.editor) this.editor.addEvent('click', this.edit.bindWithEvent(this));
    this.remover = div.getElement('a.remove_post');
    if (this.remover) this.remover.addEvent('click', this.remove.bindWithEvent(this));
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
    this.showing = true;
  },
  sendForm: function () {
    // body...
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
  remove: function(e){
    block(e);
    console.log('remove!');
  }
});

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
