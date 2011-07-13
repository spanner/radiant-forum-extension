module ForumTags
  include Radiant::Taggable
  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  include I18n
  
  class TagError < StandardError; end

  tag 'forum_css' do |tag|
    styles = tag.render("reader_css")
    styles << %{<link rel="stylesheet" href="/cleditor/jquery.cleditor.css" media="all" />} if Radiant.config['forum.toolbar?']
    styles << %{<link rel="stylesheet" href="/stylesheets/forum.css" media="all" />}
  end

  tag 'forum_js' do |tag|
    scripts = tag.render("reader_js")
    scripts << %{
      <script type="text/javascript" src="/cleditor/jquery.cleditor.js"></script>
      <script type="text/javascript" src="/cleditor/jquery.cleditor.icon.js"></script>
      <script type="text/javascript" src="/cleditor/jquery.cleditor.xhtml.js"></script>
    } if Radiant.config['forum.toolbar?']
    scripts << %{<script type="text/javascript" src="/javascripts/forum.js"></script>}
  end

  tag 'forum' do |tag|
    tag.expand
  end

  tag 'forum:topics' do |tag|
    tag.expand
  end

  desc %{
    Renders a standard list of recent topics. 
    Pass a 'limit' parameter to set the length of the list: default is 10.
    
    <pre><code>
      <r:forum:topics:latest limit="5" />
      # is the same as:
      <ul>
        <r:forum:topics:each limit="5">
          <li><r:forum:topic:link /><br /><r:forum:topic:context /></li>
        </r:forum:topics:each>
      </ul>
    </code></pre>
  }
  tag 'forum:topics:latest' do |tag|
    limit = (tag.attr['limit'] || 10).to_i
    output = "<ul>"
    Topic.latest(limit).each do |topic|
      tag.locals.topic = topic
      tag.locals.post = topic.posts.last
      output << tag.render('forum:topic:summary', tag.attr.dup)
    end
    output << "</ul>"
    output
  end

  desc %{
    Loops over the most recently-updated forum topics.
    Supply a `limit` attribute to set the number of topics shown. The default is 10.
    Within the loop you can use all the usual r:forum:topic and r:forum:post tags.
    The post tags will refer to the latest reply (or to the first post if there are no replies).
  }
  tag 'forum:topics:each' do |tag|
    output = []
    limit = (tag.attr['limit'] || 10).to_i
    Topic.latest(limit).each do |topic|
      tag.locals.topic = topic
      tag.locals.post = topic.posts.last
      output << tag.expand
    end
    output
  end

  tag 'forum:topic' do |tag|
    tag.locals.topic = Topic.find( tag.attr['id'] ) unless tag.attr['id'].blank?
    raise TagError, "can't have forum:topic without a topic" unless tag.locals.topic
    tag.expand
  end

  desc %{
    Renders a standard, minimal topic list item consisting of link and explanation.
    This is the shorthand used by forum:topics:latest but it can also be used in other settings.
    
    <pre><code>
      <r:forum:topic:summary />
      # is the same as:
      <li><r:forum:topic:link /><br /><r:forum:topic:context /></li>
    </code></pre>    
  }
  tag 'forum:topic:summary' do |tag|
    "<li>#{tag.render('forum:topic:link')}<br />#{tag.render('forum:topic:context')}</li>"
  end

  desc %{
    Renders the url of the current topic.
  }
  tag 'forum:topic:url' do |tag|
    forum_topic_path(tag.locals.topic.forum, tag.locals.topic)
  end

  desc %{
    Renders a link to the current topic using its name as the text.
  }
  tag 'forum:topic:link' do |tag|
    options = tag.attr.dup
    anchor = options['anchor'] ? "##{options.delete('anchor')}" : ''
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.render('forum:topic:name')
    %{<a href="#{tag.render('forum:topic:url')}#{anchor}"#{attributes}>#{text}</a>}
  end
  tag 'link' do |tag|
  end
  
  desc %{
    Renders the name of the reader who started the current topic.
  }
  tag 'forum:topic:author' do |tag|
    tag.locals.topic.reader.name
  end

  desc %{
    Renders the name of the current topic.
  }
  tag 'forum:topic:name' do |tag|
    tag.locals.topic.name
  end

  desc %{
    Renders the (sanitized and textilized) body of the first post in the current topic.
  }
  tag 'forum:topic:body' do |tag|
    tag.locals.topic.posts.first.body_html
  end

  desc %{
    Renders the usual context line for the current topic, but with no date.
  }
  tag 'forum:topic:context' do |tag|
    output = []
    topic = tag.locals.topic
    if tag.locals.topic.has_replies?
      output << I18n.t('forum_extension.reply_from')
      output << %{<a href="#{reader_path(tag.locals.topic.replied_by)}">#{tag.locals.topic.replied_by.name}</a>}
    else
      output << I18n.t('forum_extension.started_by')
      output << %{<a href="#{reader_path(tag.locals.topic.reader)}">#{tag.render('forum:topic:author')}</a>}
    end
    output.join(' ')
  end

  desc %{
    Renders the creation date of the current topic in a colloquial form.
  }
  tag 'forum:topic:date' do |tag|
    I18n.l tag.locals.topic.created_at, :format => :standard
  end

  desc %{
    Renders the reply date of the current topic in a colloquial form.
  }
  tag 'forum:topic:replydate' do |tag|
    I18n.l tag.locals.topic.replied_at, :format => :standard
  end

  tag 'forum:posts' do |tag|
    tag.expand
  end

  desc %{
    Loops over the posts most recently added. In effect this is very similar to calling
    r:topics:each, but there are some differences:
    
    * page comments and any other non-topic posts are included
    * here r:post tags always refer to the current post. 
      Within the topics:each loop they always refer to the last reply to that topic.
    * tag.locals.page is set if the foreground post is a page comment, so you can use
      all the usual radius tags for that page.
    
    Supply a `limit` attribute to set the number of posts shown. The default is 10.
  }
  tag 'forum:posts:each' do |tag|
    results = []
    limit = (tag.attr['limit'] || 10).to_i
    Post.latest(limit).each do |post|
      tag.locals.post = post
      tag.locals.topic = post.topic
      tag.locals.page = post.page
      results << tag.expand
    end
    results
  end

  desc %{
    This tag is generally used in double form or as a silent prefix, where it will just expand:
    
    <pre><code>
      <r:forum:post><r:link /></r:forum:post>
      # or just
      <r:forum:post:link />
    </code></pre>
    
    But if used in single form it will return a standard, minimal post list item 
    consisting of link and explanation:
    
    <pre><code>
      <r:forum:post />
      # is the same as:
      <li><r:forum:post:link /><br /><r:forum:post:context /></li>
    </code></pre>
    
    Note that the text of the link will be the name of the topic or page to which this post is attached, 
    and that within a topics:each loop any r:forum:post tags will show the last post to the topic.
  }
  tag 'forum:post' do |tag|
    tag.locals.post = Post.find(tag.attr['id']) unless tag.attr['id'].blank?
    raise TagError, "can't have forum:post without a post" unless tag.locals.post
    tag.expand if tag.locals.post
  end
  
  desc %{
    Renders a url (with pagination and anchor) for the current post. Within a topics:each loop this
    is a way to link to the last post.
  }
  tag 'forum:post:url' do |tag|
    paginated_post_path(tag.locals.post)
  end

  desc %{
    Renders a title that can be used over the post: this will be the name of its page or topic.
  }
  tag 'forum:post:name' do |tag|
    tag.locals.post.holder.title
  end

  desc %{
    Renders a link to the current post. The link text will be the page or topic title and within that
    the destination of the link will be the page and anchor for this post.
  }
  tag 'forum:post:link' do |tag|
    link_to tag.render('forum:post:name'), tag.render('forum:post:url')
  end

  desc %{
    Renders the name of the author of this post.
  }
  tag 'forum:post:author' do |tag|
    tag.locals.post.reader.name
  end

  desc %{
    Renders the (sanitized and textilized) body of the current post.
  }
  tag 'forum:post:body' do |tag|
    tag.locals.post.body_html
  end

  desc %{
    Renders a description line for the current post, which is usually something like 
    'comment added by', 'new reply from' or 'new topic begun by' followed by the author's
    name and the colloquial form of the creation date.
  }
  tag 'forum:post:context' do |tag|
    output = []
    post = tag.locals.post
    if post.page
      output << I18n.t('forum_extension.new_comment_from')
    elsif post.first?
      output << I18n.t('forum_extension.new_reply_from')
    else
      output << I18n.t('forum_extension.new_topic_from')
    end
    output << %{<a href="#{reader_path(tag.locals.post.reader)}">#{tag.render('forum:post:author')}</a>}
    output << tag.render('forum:post:date')
    output.join(' ')
  end

  desc %{
    Renders the creation date of the current post
  }
  tag 'forum:post:date' do |tag|
    I18n.l tag.locals.post.created_at, :format => :standard
  end

  # page comments are just a special case of posts that have a page but not topic
  # there is the difference that we generally want to display the whole set
  # and the added complication that they should be paginated.
  # but we only need to define some more collection and summary tags and set the post collection appropriately

  desc %{
    The address for add-a-comment links
  }
  tag 'comment_url' do |tag|
    add_comment_path(tag.locals.page)
  end

  tag 'comment_link' do |tag|
    options = tag.attr.dup
    if tag.locals.page.still_commentable?
      attributes = options.inject('') { |s, (k, v)| s << %{#{k.to_s.downcase}="#{v}" } }.strip
      text = tag.double? ? tag.expand : I18n.t("forum_extension.add_comment")
      %{<a href="#{tag.render('comment_url')}" #{attributes}>#{text}</a>}
    else
      I18n.t("forum_extension.comments_closed")
    end
  end

  desc %{
    Anything between if_comments tags is displayed only - dramatic pause - if there are comments.
  }
  tag 'if_comments' do |tag|
    tag.expand if tag.locals.page.posts.any?
  end

  desc %{
    Anything between unless_comments tags is displayed only if there are no comments.

    *Usage:*
    <pre><code><r:unless_comments>...</r:unless_comments></code></pre>
  }
  tag 'unless_comments' do |tag|
    tag.expand unless tag.locals.page.posts.any?
  end

  tag 'comments' do |tag|
    tag.expand if tag.locals.page.show_comments?
  end

  desc %{
    Renders string (internationalised) like "1 comment", "27 comments" or "no comments yet".
  }
  tag 'comments:summary' do |tag|
    if tag.locals.posts.respond_to? :total_entries
      I18n.t("forum_extension.comment_count", :count =>  tag.locals.posts.total_entries)
    else
      I18n.t("forum_extension.comment_count", :count =>  tag.locals.posts.length)
    end
  end

  desc %{
    Loops over the (paginated) comment set in ascending order of date. Within the loop you can 
    use the r:comment shorthand or any r:forum:post:* tags. Note that r:forum:topic tags won't 
    work: there is no topic to show.
  }
  tag 'comments:each' do |tag|
    results = []
    if paging = pagination_find_options
      tag.locals.posts = tag.locals.paginated_list = page.posts.paginate(paging)
    else
      tag.locals.posts = page.posts
    end
    tag.locals.posts.each do |post|
      tag.locals.post = post
      results << tag.expand
    end
    results << tag.render('pagination', tag.attr.dup) if paging
    results
  end

  desc %{
    A useful shortcut: To enable page commenting, all you have to do is put this in your layout:

    <pre><code><r:comments:all /></code></pre>
    
    It will display a (paginated) list of page comments followed by an 'add comment' link that you 
    can hook into using the supplied forum javascript or your own equivalent.
  }
  tag 'comments:all' do |tag|
    if tag.attr['paginated'] == 'true'
      tag.locals.posts = tag.locals.paginated_list = tag.locals.page.posts.paginate(pagination_parameters)
    else
      tag.locals.posts = tag.locals.page.posts
    end
    results = ""
    results << %{<div class="page_comments">}
    results << %{<p class="context">#{tag.render('comments:summary')}</p>}
    tag.locals.posts.each do |post|
      tag.locals.post = post
      results << tag.render('comment')
    end
    results << %{<div class="new_post"><div class="wrapper"><p>#{tag.render('comment_link', 'class' => 'remote post')}</p></div></div>}
    results << tag.render('pagination', tag.attr.dup)
    results << "</div>"
    results
  end

  desc %{
    A useful shortcut that renders an entire post - in much the same way as a post would appear 
    in the forum - so that it can be displayed as a comment on the page.
  }
  tag 'comment' do |tag|
    raise TagError, "can't have r:comment without a post" unless post = tag.locals.post
    if tag.double?
      tag.locals.reader = post.reader
      tag.expand
    else
      output = %{<div class="post"><div class="wrapper">}
      output << %{<div class="post_header">}
      output << %{<h2>#{tag.render("forum:post:reader")}</h2>}
      output << %{<p class="context">#{tag.render("forum:post:context")}</p>}
      output << %{</div>}
      output << %{<div class="post_body">}
      output << tag.render("forum:post:body")
      output
    end
  end




  desc %{
    Expands if this group has any forums.
    
    <pre><code><r:group:if_forums>...</r:group:if_forums></code></pre>
  }
  tag "group:if_forums" do |tag|
    tag.expand if tag.locals.group.forums.any?
  end

  desc %{
    Expands if this group does not have any forums.
    
    <pre><code><r:group:unless_forums>...</r:group:unless_forums></code></pre>
  }
  tag "group:unless_forums" do |tag|
    tag.expand unless tag.locals.group.forums.any?
  end

  desc %{
    Expands if this group has any topics.
    
    <pre><code><r:group:if_topics>...</r:group:if_topics></code></pre>
  }
  tag "group:if_topics" do |tag|
    tag.expand if tag.locals.group.topics.any?
  end

  desc %{
    Expands if this group does not have any topics.
    
    <pre><code><r:group:unless_topics>...</r:group:unless_topics></code></pre>
  }
  tag "group:unless_topics" do |tag|
    tag.expand unless tag.locals.group.topics.any?
  end

  desc %{
    Loops through the forums belonging to this group.
    
    <pre><code><r:group:forums:each>...</r:group:forums:each /></code></pre>
  }
  tag "group:forums" do |tag|
    tag.locals.forums = tag.locals.group.forums
    tag.expand
  end
  tag "group:forums:each" do |tag|
    result = []
    tag.locals.forums.each do |forum|
      tag.locals.forum = forum
      result << tag.expand
    end
    result
  end

  desc %{
    Loops through the latest topics in all forums belonging to this group.
    
    <pre><code><r:group:latest_topics:each count="10">...</r:group:latest_topics:each></code></pre>
  }
  tag "group:latest_topics" do |tag|
    count = tag.attr["count"] || 10
    tag.locals.topics = tag.locals.group.topics.latest(count)
    tag.expand
  end
  tag "group:latest_topics:each" do |tag|
    result = []
    tag.locals.topics.each do |topic|
      tag.locals.topic = topic
      result << tag.expand
    end
    result
  end

  desc %{
    If the group has only one forum, this presents a simple new-topic link around the supplied text. 
    If it has several forums, this offers a list with the supplied text as the heading.
    
    <pre><code><r:group:new_topic_link /></code></pre>
  }
  tag "group:new_topic_link" do |tag|
    forums = tag.locals.group.forums
    text = tag.double? ? tag.expand : "Start a new conversation"
    result = ""
    case forums.length
    when 0
    when 1
      result << %{<a href="#{new_forum_topic_path(forums.first)}">#{text}</a>}
    else
      result << %{<h3>#{text}</h3><ul>}
      result << forums.collect{|forum| %{<li><a href="#{new_forum_topic_path(forum)}">#{forum.name}</a></li>}}
      result << "</ul>"
    end
    result
  end

end
