# Forum

This is a simple but comprehensive forum implementation that plugs into radiant. It's fairly well-featured, including:

* forums, topics, posts etc
* page comments
* rss feeds of pretty much anything (including search results and readers)
* textile-formatted messages with html whitelisting
* multiple message attachments and nice image-handling

I've tried to keep it simple and tidy both inside and out. This is helped by the fact that all the user-management is in the reader extension, so you should find this one very easy to adapt and extend. 

The forum was derived long ago from Beast and the fossilised bones will still be visible here and there. It has been in use on various sites in various versions for the last three years, but in consolidating it here and making it ready for publication I've pretty much refactored the whole thing. Some of it is quite new, then, and I've probably optimised new bugs into it. 

The forum is compatible with multi_site but you have to use [our fork](https://github.com/spanner/radiant-multi-site-extension) if you want forums and readers site-scoped.

## Status

I've just spent three days chasing gremlins out of this so it should be in good shape. I use it with some mootools-based scripts for inline editing. When I get a moment I'll generalise those and include them here. Until then it should work fine in the old-fashioned way.

## Still to do

* Moderators among readership
* Reinstate message preview
* Reinstate email-monitoring
* Message-flagging button
* Admin pages that suck a lot less
* Anonymous page-comment option

## Requirements

Radiant 0.8 with the [reader](http://github.com/spanner/radiant-reader-extension) extension, [paperclipped](https://github.com/kbingman/paperclipped/tree) and [share_layouts](https://github.com/radiant/radiant-share-layouts-extension/tree).

## Installation

I don't think Ray knows about these extensions, but the forum is very standard:

	git submodule add git://github.com/spanner/radiant-forum-extension.git vendor/extensions/forum

Check the extension loading order in environment.rb (see below) and then:

	rake radiant:extensions:forum:migrate
	rake radiant:extensions:forum:update

In future this might be all you need:

	rake rake ray:extension:install name="forum"

As well as the basic machinery this should give you:

* a basic forum.css that you will want to improve upon,
* an admin/forum.css that you can probably leave alone, 
* a sample layout that should be enough to let you experiment

## Load order

You will want this in your environment.rb

	config.extensions # [ :share_layouts, :multi_site, :reader, :all ] 
	
If you add [reader_groups](http://github.com/spanner/radiant-reader_groups-extension) then that should be specified after :reader, and incidentally you would probably also want to install the [group_forums](http://github.com/spanner/radiant-group_forums-extension) glue that lets you make a forum private to a group.

You

## Administration

The forum is easy to use and almost entirely separate from your page hierarchy. Forums - which are described as 'discussion categories' most of the time and pushed into the background - are created and edited in the admin interface, and there readers can also (soon) be promoted to moderate selected forums. Everything else happens through the reader interface including the editing and deletion of posts.

## Page Comments

To enable page comments, all you have to do is put `<r:comments:all />` somewhere in the layout (or in a snippet or on an individual page). Behind the scenes this will create a dedicated forum for page comments and a topic for each page as it is commented upon. The rest of the mechanism is the same, and the comments themselves are just posts. 

The page cache means we can't put anything personal on the page itself - no edit controls or logout buttons - but you can get around this with a remote call. Put `<r:comments:remote />` on the page instead and a stub will be included suitable for your scripts to grab. A simple example is included in forum.js.

You can also use `<r:comments:each>...</r:comments:each>` and the various r:comment tags to compose page comments however you like. See the tags-available documentation for details.

## Security & Spam

The reader extension includes email confirmation and a simple honeytrap that should prevent most bots from registering. The post forms include proper XSS protection via the old white_list plugin and the usual CSRF protection is enabled. I probably need to go through making sure everything is h'd that should be.

## Ajax

I've published this in the simplest form possible, on the assumption that everyone will want to use it in a different way. A sample javascript front end (based on mootools but without too much fanciness) is included to make things a little bit more friendly: it includes edit-in-place for posts, a bit of code to handle bringing page comments into the page, and some generally-useful routines like notice faders. That's about it, but I hope it will provide a starting point. The 'forum_example' layout that is created on installation should bring in that javascript and enough css for you to see it all working.

## Smilies

I've included a basic set here and a redcloth extension that catches :smile: notation alongside the textile markup. There's a javascript front end in the works for that - click on the smiley, you know - which will also soon appear here.

## Author & Copyright

* William Ross, for spanner. will at spanner.org
* Originally based on dear old Beast, currently not visible at [http://beast.caboo.se](http://beast.caboo.se)
* Copyright 2007-9 spanner ltd
* released under the same terms as Rails and/or Radiant