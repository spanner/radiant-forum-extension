# Forum

This is a simple but clean forum implementation that plugs into radiant. It's fairly well-featured, including 

* rss feeds at several levels
* email monitoring of topics
* textile-formatted messages with html whitelisting
* message attachments

but I've tried to keep it clean and simple both inside and out. This is helped by the fact that all the user-management is in the reader extension, so you should find this one very easy to adapt and extend. 

The forum was derived long ago from Beast and the bones will still be visible here and there. It has been in use on various sites in various versions for the last two years, but in consolidating it here and making it ready for publication I've pretty much refactored the whole thing. Some of it is quite new, then, and may have exciting new bugs in it. 

The forum is compatible with multi_site but you have to use our fork (https://github.com/spanner/radiant-multi-site-extension) if you want forums and readers site-scoped.

## Status

This version is now in testing and on a couple of small sites.

## Still to do

* Moderators among readership
* Reinstate message preview
* Message-problem button
* Admin pages that suck a lot less

## Requirements

The reader extension, paperclipped and share_layouts.

## Installation

At the moment Ray doesn't know about these extensions. You will need to jump through some hoops to install [reader](http://github.com/spanner/radiant-reader-extension) but after that the forum is very simple:

	git submodule add git://github.com/spanner/radiant-forum-extension.git vendor/extensions/forum
	rake radiant:extensions:forum:migrate
	rake radiant:extensions:forum:update

In future this ought to be all you need:

	rake rake ray:extension:install name="forum"

As well as the basic machinery this should give you:

* a basic forum.css that you will want to improve upon,
* an admin/forum.css that you can probably leave alone, 
* a sample javascript front end. It uses mootools but in a very generic way and should be easy to adapt.
* various useful images. 
* a sample layout that should be enough to let you experiment

## Load order

For best results, you will want this in your environment.rb

	config.extensions # [ :share_layouts, :multi_site, :reader, :all ] 
	
If you add [reader_groups](http://github.com/spanner/radiant-reader_groups-extension) then that should be specified after :reader, and incidentally you would probably also want to install the [group_forums](http://github.com/spanner/radiant-group_forums-extension) glue that lets you make a forum private to a group.

## Administration

The forum is easy to use and almost entirely separate from your page hierarchy. Forums - which are described as 'discussion categories' most of the time and pushed into the background - are created and edited in the admin interface, and there readers can also (soon) be promoted to moderate selected forums. Everything else happens through the reader interface including the editing and deletion of posts.

## Page Comments

To enable page comments, all you have to do is put `<r:comments:all />` somewhere in the layout (or in a snippet or even on an individual page). Behind the scenes this will create a dedicated forum for page comments and a topic for each page as it is commented upon. The rest of the mechanism is the same, and the comments themselves are just posts. 

The page cache means we can't put anything personal on the page itself - no edit controls or logout buttons - but you can get around this with a remote call. Put `<r:comments:remote />` on the page instead and a suitable stub will be included ready for your scripts to grab. A simple example is included in forum.js.

You can also use `<r:comments:each>...</r:comments:each>` and the various r:comment tags to compose page comments however you like. See the tags-available documentation for details.

## Security & Spam

The reader extension includes email confirmation and a simple honeytrap that should prevent most bots from registering. The post forms include proper XSS protection via the old white_list plugin and the usual CSRF protection is enabled. I probably need to go through making sure every is h'd that should be.

## Ajax

I've published this in the simplest form possible, on the assumption that everyone will want to use it in a different way. A sample javascript front end is included to make things a little bit more friendly: it includes edit-in-place for posts, a bit of code to handle bringing page comments into the page, and some generally-useful routines like notice faders. That's about it, but I hope it will provide a starting point. The 'forum_example' layout that is created on installation should bring in that javascript and enough css for you to see it all working.

## Smilies

I've included a basic set here and a redcloth extension that catches :smile: notation alongside the textile markup. There's a javascript front end for that too - click on the smiley, you know - which will soon appear here.

## Author & Copyright

William Ross, for spanner. will at spanner.org
Originally based on dear old Beast, currently not visible at [http://beast.caboo.se](http://beast.caboo.se)
Copyright 2007-9 spanner ltd
released under the same terms as Rails and/or Radiant