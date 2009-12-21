// self-replacing links
// puts the get results in place of the link.

var InlineLink = new Class({
  initialize: function (a) {
    this.link = a;
    this.link.onclick = this.sendLink.bindWithEvent(this);
    this.catcher = new Element('div', {'class' : 'remote_content'}).wraps(this.link);
    this.catcher.set('load', {
      onRequest: this.waiting.bind(this),
      onSuccess: this.finish.bind(this),
      onFailure: this.fail.bind(this)
    });
  },
  sendLink: function (e) {
    unevent(e);
    this.link.blur();
    this.catcher.load(this.link.get('href'));
  },
  finish: function (response) {
    activate(this.catcher);
    this.catcher.highlight('#f27877');
    activate(this.catcher);
  },
  fail: function (response) {
    this.notWaiting();
    this.catcher.addClass('failed');
  }, 
  waiting: function () {
    this.link.addClass('waiting');
  },
  notWaiting: function () {
    this.link.removeClass('waiting');
  }
});

// self-replacing forms
// puts the post results in place of the form.

var InlineForm = new Class ({
  initialize: function (form) {
    this.form = form;
    var catchers = this.form.getParents().filter(function (parent) { return parent.hasClass('remote_content'); });
    this.catcher = catchers[0] || new Element('div', {'class' : 'remote_content'}).wraps(this.form);
    this.catcher.set('load', {
      url: this.form.get('action'),
      onRequest: this.waiting.bind(this),
      onSuccess: this.finish.bind(this),
      onFailure: this.fail.bind(this)
    });
    this.form.onsubmit = this.sendForm.bindWithEvent(this);
  },
  
  sendForm: function (e) {
    unevent(e);
    this.catcher.get('load').post(this.form);
  },

  finish: function (response) {
    activate(this.catcher);
    this.catcher.highlight('#f27877');
    activate(this.catcher);
  },
  
  fail: function (argument) {
    this.notWaiting();
    this.catcher.addClass('failed');
  }, 

  waiting: function () {
    this.form.getElements('input').each(function (input) { input.disabled = true; });
    this.form.getElement('p.buttons').addClass('waiting');
  },
  
  notWaiting: function () {
    this.form.getElements('input').each(function (input) { input.disabled = false; });
    this.form.getElement('p.buttons').removeClass('waiting');
  }  
});





activations.push(function (scope) {
  scope.getElements('a.inline').each(function (a) { new InlineLink(a); });
  scope.getElements('a.remote_content').each(function (a) { new InlineLink(a).sendLink(); });
  scope.getElements('form.inline').each(function (form) { new InlineForm(form); });
});
