# Forum

This is a simple but comprehensive forum implementation that plugs into radiant. It's fairly well-featured, including:

* forums, topics, posts etc
* page comments
* simple but effective forum search
* rss feeds of pretty much anything (including search queries and individual authors)
* textile-formatted messages with html sanitized
* smilies :(
* multiple message attachments and helpful image-handling
* configurable message-editing interval during which authors can make corrections

I've tried to keep it simple and tidy both inside and out. This is helped by the fact that all the user-management is in the reader extension, so you should find this one easy to adapt and extend. 

The forum was derived long ago from [Beast](http://beast.caboo.se) and the fossilised bones will still be visible here and there. It has been in use on various sites in various versions for three years, but in making it ready for publication I've pretty much refactored the whole thing and probably optimised new bugs into it. Please let me know as soon as you spot one.

## Status

Mature and stable, but I'm a bit habitual with it so may have overlooked some rough edges in parts of the interface I don't visit much. It would benefit from wider use. 

There's a lot going on here and plenty of places for me to hide bugs, but the tests are fairly thorough.

## Latest

* Quite a lot of tidying up and trimming of the interface
* sample javascripts and layout updated
* Updated for 0.8.1 with gem and extension dependencies, and many small fixes to keep up with the `reader` and `group_forum` extensions.

## Still to do

* Moderators among readership
* Reinstate message preview
* Reinstate email-monitoring
* Message-problem button
* Admin pages that are less crappy
* Anonymous page-comment option

## Requirements

Radiant 0.8.1 (we're using the new config machinery) with the [reader](http://github.com/spanner/radiant-reader-extension) extension. Reader has a few requirements of its own so it's best to install that one first, make sure it's testing clean and then install the forum.

We also require [will_paginate](http://github.com/mislav/will_paginate/) and [paperclip](http://github.com/thoughtbot/paperclip/) as gems. The latter is for post attachments, and if you're using [paperclipped](http://github.com/kbingman/paperclipped) (which vendors paperclip) then you can probably skip it. Otherwise:

	sudo rake gems:install
	
should get everything you need. 

**Please note that the github / gemcutter changes may mean that you have to rerun `rake gems:install` to reinstall `will_paginate`, which is no longer namespaced.**

The forum is compatible with multi_site but you have to use [our fork](https://github.com/spanner/radiant-multi-site-extension) if you want forums and readers site-scoped.

## Installation

The usual:

	git submodule add git://github.com/spanner/radiant-forum-extension.git vendor/extensions/forum

Check the extension loading order in environment.rb (you will need `share_layouts`, `reader` and perhaps `multi_site` to load before this one) and then:

	rake radiant:extensions:forum:migrate
	rake radiant:extensions:forum:update

As well as the basic machinery this should give you:

* a basic forum.css that you will want to improve upon,
* an admin/forum.css that you can probably leave alone, 
* a sample layout that should be enough to let you experiment
	
## Administration

The forum is easy to use and almost entirely separate from your page hierarchy. Forums - which are described as 'discussion categories' most of the time and not emphasised much in the reader-facing pages - are created and edited in the admin interface, and there readers can also (soon) be promoted to moderate selected forums. Everything else is done through the reader interface including the editing and deletion of posts and topics.

## Configuration

A few config options can be set:

* `forum.layout` should be the name of the layout you want to use for reader-facing forum pages. See below for more detail.
* `forum.default_forum` is the name of the forum that will be selected by default in the new-message form
* `forum.editable_period` is the number of minutes for which posts remain editable by their authors once they have been submitted

## Layouts

We use `share_layouts` to present your forum pages inside the radiant layout of your choice. Set the config option 'forum.layout' to the name of the layout you want to use (or see below for multi_site instructions). Your layout can work in the usual way: all we do is define page parts for you to include with `<r:content part="something" />`. These are the parts available:

* the main page content (that you get with a bare `<r:content />`) gives you the main list, object or form.
* 'pagetitle' will be the main page heading (eg the name of the topic): `<r:content part="pagetitle" />`
* 'breadcrumbs' is what you'd expect: usually something simple like Forum > Category name
* 'breadhead' is an up-one-level link that you may want to include in the page header
* 'feed' is an icon link to the RSS feed for whatever you are currently looking at (and works for most things including searches, of which more below)
* 'mugshot' is a gravatar for the author of this topic or post
* 'credits' is the authorship summary for this topic or post

These parts are only defined where they're relevent, so you can do something like this:

	<h1 class="pagetitle">
	  <r:content part="mugshot" />
	  <r:content part="breadhead" />
	  <r:content part="pagetitle" />
	  <r:content part="feed" />
	</h1>

and it will look right for all the forum pages. 

You probably also want to include this somewhere, as on all reader-service pages:

	<r:if_reader><r:reader:controls /></r:if_reader>

Have a look at the included sample layout for a starting point.

## Multi_site

The forum is fine under multi_site. If you use [our version](http://github.com/spanner/radiant-multi-site-extension) then everything will be site-scoped for you. In that case, the forum layout is chosen for each site using a dropdown on the (currently extremely scruffy) site-editing page. Everything else works in just the same way and you should be able to run several forums next to each other without problems.

## Private discussion

If you install the [reader_group](http://github.com/spanner/radiant-reader_group-extension) and [group_forum](http://github.com/spanner/radiant-group_forum-extension) extensions then your forums can be made visible only to designated groups, as with pages and other groupable items.

## Searching the forum

The forum has its own simple search mechanism. It's not very bright but it has two great advantages: you can combine text search with filtering by author and category, and you can bookmark any search query as an RSS feed to be alerted when new posts match that search. There are arguments for integrating this with eg `sphinx_search` but at the moment I quite like keeping them separate: I find that searching for messages is not the same as searching for pages, but usually a different group seeking different results. Let me know if you disagree.

To enable the search, you can either link to `/forum/posts/search` or put `<r:forum_search>` somewhere in your forum layout. See the tag documentation for control of the search form presentation.

## Page Comments

To enable page comments, all you have to do is put `<r:comments:all />` somewhere in the layout (or in a snippet or on an individual page). Behind the scenes this will create a dedicated forum for page comments and a topic for each page as it is commented upon. The rest of the mechanism is the same, and the comments themselves are just posts. 

The page cache means we don't want anything personal on the page itself - no edit controls or logout buttons - but there are a couple of ways you can get around this with a remote call. 

* Put `<r:comments:remote />` on the page instead and a stub will be included suitable for your scripts to grab. A simple example is included in platform/forum.js.
* `<r:comments:all /><r:comments:link />` is more efficient but less friendly: it will give you a static list of all comments followed by a reply link. Posting a comment clears the page cache, btw.

You can also use `<r:comments:each>...</r:comments:each>` and the various r:comment tags to compose page comments however you like. See the tags-available documentation for details.

## Security & Spam

The reader extension includes email confirmation and a simple honeytrap that should prevent most bots from registering. The forum includes proper XSS protection via the sanitize gem and the usual CSRF protection is enabled. You ought to be relatively spam-free.

## Scripting the forum interface

I've presented this in the simplest way possible, on the assumption that everyone will want to do their own thing with it. An unobtrusive javascript front end (based on mootools but without much fanciness) is included to make things a little bit more friendly: it includes edit-in-place for posts, a bit of code to handle bringing page comments into the page, and some generally-useful routines like notice faders. That's about it, but I hope it will provide a starting point. The 'forum_example' layout that is created on installation should bring in that javascript and enough css for you to see it all working. For local reasons it's all stored under `javascripts/platform/...`

## Smilies

I've included a basic set here and a redcloth extension that catches :smile: notation alongside the textile markup. There's a javascript front end in the works for that - click on the smiley, you know - which will also soon appear here.

## Bugs

Very likely. [Github issues](http://github.com/spanner/radiant-forum-extension/issues), please, or for little things an email or github message is fine.

## Author & Copyright

* William Ross, for spanner. will at spanner.org
* Originally based on dear old Beast, currently not visible at [http://beast.caboo.se](http://beast.caboo.se)
* Copyright 2007-9 spanner ltd
* released under the same terms as Rails and/or Radiant