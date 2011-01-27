# Forum

This is a tidy but comprehensive forum implementation that plugs into radiant and supports both discussion forums and page comments. 

This new (as I write) version 2 is a complete rewrite with a lot of internal clarification in preparation for rails 3. It's in late beta at the moment: bug fixes, documentation and packaging for public release.

The forum is designed to be pick-and-mixed with other radiant extensions, so it's very focused on being an excellent forum and doesn't do anything else. I hope you will find it's very good at what it does do:

* forums, topics, posts etc
* page comments
* simple but effective forum search
* rss feeds of pretty much anything (including search queries and individual authors)
* multiple message attachments and helpful image-handling
* configurable message-editing interval during which authors can make corrections
* minimal wysiwig message editing including smilies :(
* ajax edit-in-place

I've tried to keep it simple and tidy both inside and out. This is helped by the fact that all the user-management is in the reader extension, so you should find this is easy to adapt and extend. The admin interface on the other hand is pretty basic: we expect most administration to happen through the public pages but there does need to be at least a dashboard to give a better overview. That will come soon.

As far as I know this is the best forum software available for rails. I look forward to finding out that it's not.

## Status

This code has been surviving in the world for four or five years (and more, since some it originally came from Beast), but this version is about 75% new and you know what that means: new bugs. Github issues, please.

## Latest

* Inline editing with editable-for-interval setting
* Punymce-based wysiwig editing.
* Page comments data structure simplified. Migration required.
* Everything internationalized
* Scripting all moved over to jquery (mootools was too niche, sadly)
* Uses the new radiant configuration interface
* Basic admin interface as well as readerland administration
* Editable interval for messages

This version is not wholly multi-site compatible at the moment, since it relies heavily on configuration items that are not yet site-scoped. They will be soon.

## Still to do

* Allow moderation by selected readers
* Message-problem button
* Admin dashboard

## Requirements

Radiant 0.9.2 (we're using the new configuration interface) with the [reader](http://github.com/spanner/radiant-reader-extension) extension. Reader has a few requirements of its own so it's best to install that one first, make sure it's testing clean and then install the forum.

We also require [will_paginate](http://github.com/mislav/will_paginate/) and [paperclip](http://github.com/thoughtbot/paperclip/) as gems but you will already have those.

	sudo rake gems:install
	
should get everything you need. 

The forum is compatible with multi_site but you should use [sites](https://github.com/spanner/radiant-sites-extension) instead if you want forums and readers site-scoped.
	
## Administration

The forum is easy to use and almost entirely separate from your page hierarchy. Forums - which are described as 'discussion categories' most of the time and not emphasised much in the reader-facing pages - are created and edited in the admin interface, and there readers can also (soon) be promoted to moderate selected forums. Everything else is done through the reader interface including the editing and deletion of posts and topics.

## Configuration

There is now a configuration panel for the forum and you shouldn't have to do any console-tinkering.

## Layouts

Forum pages have their own controllers but they are presented inside your normal radiant layouts. Use the configuration interface to choose the layout you want to use. Your layout can work in the usual way: all we do is define page parts for you to include with `<r:content part="something" />`. These are the parts available:

* the main page content (that you get with a bare `<r:content />`) gives you the main list, object or form.
* 'pagetitle' will be the main page heading (eg the name of the topic): `<r:content part="pagetitle" />`
* 'breadcrumbs' is what you'd expect: usually something simple like Forum > Category name
* 'breadhead' is a minimal breadcrumb link that you may want to include in the page header
* 'feed' is an icon link to the RSS feed for whatever you are currently looking at (and works for most things including searches, of which more below)
* 'mugshot' is a gravatar for the author of this topic or post
* 'credits' is the authorship summary for this topic or post

These parts are only defined where they're relevant, so you can do something like this:

	<h1 class="pagetitle">
	  <r:content part="person" />
	  <r:content part="breadhead" />
	  <r:title />
	  <r:content part="feed" />
	</h1>

and it will look right for all the forum pages. 

You probably also want to include this somewhere, as on all reader-service pages:

	<r:if_reader><r:reader:controls /></r:if_reader>

Have a look at the included sample layout for a starting point.

## Private discussion

If you install the [reader_group](http://github.com/spanner/radiant-reader_group-extension) and [group_forum](http://github.com/spanner/radiant-group_forum-extension) extensions then your forums can be made visible only to designated groups, as with pages and other groupable items.

## Searching the forum

The forum has its own simple search mechanism. It's not very bright but it has two great advantages: you can combine text search with filtering by author and category, and you can bookmark any search query as an RSS feed to be alerted when new posts match that search. There are arguments for integrating this with eg `sphinx_search` but at the moment I quite like keeping them separate: I find that searching for messages is not the same as searching for pages, but usually a different group seeking different results. Let me know if you disagree.

The search is implemented just by passing parameters to posts_controller#index, so you can link to addresses like `/forum/posts?q=something&reader_id=45` or put `<r:forum_search>` somewhere in your forum layout. See the tag documentation for control of the search form presentation.

## Page Comments

To enable page comments, all you have to do is put `<r:comments:all />` somewhere in the layout (or in a snippet or on an individual page). Behind the scenes this will create a dedicated forum for page comments and a topic for each page as it is commented upon. The rest of the mechanism is the same, and the comments themselves are just posts. 

The page cache means we don't want anything personal on the page itself - no edit controls or logout buttons - but there are a couple of ways you can get around this with a remote call. 

* Put `<r:comments:remote />` on the page instead and a stub will be included suitable for your scripts to grab. A simple example is included in platform/forum.js.
* `<r:comments:all /><r:comments:link />` is more efficient but less friendly: it will give you a static list of all comments followed by a reply link. Posting a comment clears the page cache, btw.

You can also use `<r:comments:each>...</r:comments:each>` and the various `r:forum:post` tags to compose page comments however you like. See the tags-available documentation for details.

## Security & Spam

The reader extension includes email confirmation and a simple honeytrap that should prevent most bots from registering. The forum includes proper XSS protection via the sanitize gem and the usual CSRF protection is enabled. You ought to be relatively spam-free.

## Scripting the forum interface

The forum comes with some jquery-based scripting to handle inline administration and a few other useful functions. It's entirely unobtrusive and I assume you will want to replace or extend it. You should find the page DOM is quite simple and robust.

## Smilies

Included here is a redcloth extension to handle emoticons of the type inserted by the punymce toolbar we're using. Since we have control of both ends I've customised the set to make accidental emoticons less likely. There will soon be an option to disable them completely.

## Bugs

In the short term, quite likely. [Github issues](http://github.com/spanner/radiant-forum-extension/issues), please, or for little things an email or github message is fine.

## Author & Copyright

* William Ross, for spanner. will at spanner.org
* Originally based on dear old Beast, currently not visible at [http://beast.caboo.se](http://beast.caboo.se)
* Copyright 2007-11 spanner ltd
* released under the same terms as Rails and/or Radiant