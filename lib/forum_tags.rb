module ForumTags
  include Radiant::Taggable

  class TagError < StandardError; end


  #### FORUMS
  
  desc %{
    Root tag for the forums collection. At the moment, just expands.
    
    *Usage:*
    <pre><code><r:forums>...</r:forums></code></pre>
  }
  tag 'forums' do |tag|
    # tag.locals.forums = Forum.find(:all)
    tag.expand
  end

  desc %{
    Renders the total number of forums.
  }
  tag 'forums:count' do |tag|
    tag.locals.forums.count
  end
      
  desc %{
    Cycles through each of the forums. Inside this tag all forum and topic tags
    are mapped to the current forum. As usual, takes same sorting options as
    @<r:children:each>@, except that status options are: (what?)
    
    *Usage:*
    <pre><code><r:forums:each [offset="number"] [limit="number"] [by="attribute"] [order="asc|desc"]>
     ...
    </r:forums:each>
    </code></pre>
  }
  tag 'forums:each' do |tag|
    options = forums_find_options(tag, Forum)
    result = []
    forums = Forum.find(:all, options)
    forums.each do |item|
      tag.locals.forum = item
      result << tag.expand
    end 
    result
  end
  
  desc %{
    Inside this tag all forum tags refer to the first forum matching the supplied title, 
    if any, or else the forum locally set by forums:each
     
    *Usage:*
    <pre><code><r:forum name="name_of_forum">...</r:forum></code></pre>
  }
  tag 'forum' do |tag|
    tag.locals.forum = Forum.find_by_title(tag.attr['name']) if tag.attr['name']
    raise TagError.new("no forum!") unless tag.locals.forum
    tag.expand
  end

  desc %{
    Renders the id of the currently active forum.
  }
  tag 'forum:id' do |tag|
    raise TagError, "`forum:id' tag requires that a forum be present." unless tag.locals.forum
    tag.locals.forum.id
  end

  desc %{
    Renders the address of the currently active forum.
  }
  tag 'forum:url' do |tag|
    raise TagError, "`forum:url' tag requires that a forum be present." unless tag.locals.forum
    # can't get at routing helpers in a model. grr.
    "/forums/#{tag.locals.forum.id}"
    end
  
  desc %{
    Renders a link to the currently active forum. Link text defaults to name of forum.
    As with all forum tags, name can be supplied or forums:each can define forum.
    All other attributes passed on to html <a> tag (exactly as for page links).

    *Usage:*
    <pre><code>
      <r:forum:link />
      <r:forum:link>Visit forum</r:forum:link>
    </code></pre>

  }
  tag 'forum:link' do |tag|
    raise TagError, "`forum:link' tag requires that a forum be present." unless tag.locals.forum
    options = tag.attr.dup
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.render('forum:name')
    %{<a href="#{tag.render('url')}"#{attributes}>#{text}</a>}
  end

  desc %{
    Renders the name of the currently active forum.
  }
  tag 'forum:name' do |tag|
    raise TagError, "`forum:name' tag requires that a forum be present." unless tag.locals.forum
    tag.locals.forum.name
  end
  
  desc %{
    Renders the description of the currently active forum.
  }
  tag 'forum:description' do |tag|
    raise TagError, "`forum:description' tag requires that a forum be present." unless tag.locals.forum
    tag.locals.forum.body_html      # defined by white_list_formatted_content
  end

  desc %{
    Renders a 'new topic' link for the current forum.

    *Usage:*
    <pre><code>
      <r:forum:new_topic_link class="inlineform">New Topic</r:forum:new_topic_link>
      <r:forum:new_topic_link title="start a conversation" />
    </code></pre>
  }
  tag 'forum:new_topic_link' do |tag|
    raise TagError, "`forum:new_topic_link' tag requires that a forum be present." unless tag.locals.forum
    text = tag.double? ? tag.expand : options['title']
    options['class'] ||= 'newtopic'
    %{<a href="#{forum_new_topic_url(tag.locals.forum)}" class="#{options['class']}">#{text}</a>}
  end
  
  #### TOPICS 

  desc %{
    Root tag for the topics collection. Preloads and expands. Requires that a forum be set.
    
    *Usage:*
    <pre><code><r:topics>...</r:topics></code></pre>
  }
  tag 'topics' do |tag|
    tag.locals.topics = tag.locals.forum ? tag.locals.forum.topics : Topic.finder
    tag.expand
  end

  desc %{
    Renders the total number of topics in the current forum.
  }
  tag 'topics:count' do |tag|
    tag.locals.topics.count
  end

  desc %{
    Cycles through each of the topics in the currently active forum.
    Usual sorting options.
    
    *Usage:*
    <pre><code><r:topics:each [offset="number"] [limit="number"] [by="attribute"] [order="asc|desc"]>
     ...
    </r:topics:each>
    </code></pre>
  }
  tag 'topics:each' do |tag|
    options = forums_find_options(tag, Topic)
    result = []
    tag.locals.topics.find(:all, options).each do |item|
      tag.locals.topic = item
      result << tag.expand
    end 
    result
  end

  desc %{
    Inside this tag all topic tags refer to the first topic matching the supplied title, 
    if any, or else the forum locally set by forums:each
     
    *Usage:*
    <pre><code>
      <r:topic name="name_of_topic">...</r:topic>
    </code></pre>
  }
  tag 'topic' do |tag|
    if tag.attr['name']
      tag.locals.topic = tag.locals.forum ? tag.locals.forum.topics.find_by_title(tag.attr['name']) : Topic.find_by_title(tag.attr['name'])
    end
    raise TagError.new("no topic!") unless tag.locals.topic
    tag.expand
  end

  desc %{
    Renders the id of the currently active topic.
  }
  tag 'topic:id' do |tag|
    raise TagError, "`topic:id' tag requires that a topic be present." unless tag.locals.topic
    tag.locals.topic.id
  end

  desc %{
    Renders the title of the currently active topic.
  }
  tag 'topic:title' do |tag|
    raise TagError, "`topic:title' tag requires that a topic be present." unless tag.locals.topic
    tag.locals.topic.title
  end
  
  desc %{
    Renders the title of the currently active topic.
  }
  tag 'topic:body' do |tag|
    raise TagError, "`topic:title' tag requires that a topic be present." unless tag.locals.topic
    tag.locals.topic.body_html
  end

  desc %{
    Renders a link url for the currently active topic.
  }
  tag 'topic:url' do |tag|
    raise TagError, "`topic:url' tag requires that a topic be present." unless tag.locals.topic
    "/forums/#{tag.locals.topic.forum.id}/#{tag.locals.topic.id}"
  end

  desc %{
    Renders a link to the currently active topic. Link text defaults to name of topic.
    As with all topic tags, name can be supplied or topics:each can define forum.
    All other attributes passed on to html <a> tag (exactly as for page links).

    *Usage:*
    <pre><code>
      <r:topic:link />
      <r:topic:link>read topic</r:topic:link>
    </code></pre>

  }
  tag 'topic:link' do |tag|
    raise TagError, "`topic:link' tag requires that a topic be present." unless tag.locals.topic
    options = tag.attr.dup
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.render('topic:title')
    url = tag.render('topic:url')
    %{<a href="#{url}"#{attributes}>#{text}</a>}
  end



  #### POSTS


  desc %{
    Root tag for the posts collection. Preloads and expands.
    if no topic, gathers all posts from all forums, much like the latest feed.
    if you want to show page comments, use r:comments:*
    
    *Usage:*
    <pre><code><r:posts>...</r:posts></code></pre>
  }
  tag 'posts' do |tag|
    logger.warn "!!! posts"
    tag.locals.posts = tag.locals.topic ? tag.locals.topic.posts : Post.finder
    logger.warn "!!! tag.locals.posts: #{tag.locals.posts.size}"
    tag.expand
  end

  desc %{
    Renders the total number of posts
  }
  tag 'posts:count' do |tag|
    tag.locals.posts.count
  end
  
  desc %{
    Cycles through each of the posts in the currently active topic
    Usual sorting options.
    
    *Usage:*
    <pre><code><r:posts:each [offset="number"] [limit="number"] [by="attribute"] [order="asc|desc"]>
     ...
    </r:posts:each>
    </code></pre>
  }
  tag 'posts:each' do |tag|
    options = forums_find_options(tag)
    result = []
    tag.locals.posts.find(:all, options).each do |item|
      tag.locals.post = item
      result << tag.expand
    end 
    result
  end

  desc %{
    Sets foreground post to first in list 
    (which might be topic list or everything list) 
    usual sort options
  }
  tag 'posts:first' do |tag|
    options = forums_find_options(tag)
    tag.locals.post = tag.locals.posts.find(:first, options)
    tag.expand
  end

  desc %{
    Sets foreground post to last in list (ie most recent)
    (this might be topic list or everything list) 
    usual sort options
  }
  tag 'posts:last' do |tag|
    options = forums_find_options(tag)
    posts = tag.locals.posts.find(:all, options)
    tag.locals.post = posts.last
    tag.expand
  end

  tag 'post' do |tag|
    tag.expand
  end

  desc %{
    Renders the id of the currently active post.
  }
  tag 'post:id' do |tag|
    raise TagError, "`post:id' tag requires that a post be present." unless tag.locals.post
    tag.locals.post.id
  end

  desc %{
    Renders the body of the currently active post.
  }
  tag 'post:description' do |tag|
    raise TagError, "`post:description' tag requires that a post be present." unless tag.locals.post
    post = tag.locals.post
    post == post.topic.posts.first ? "new topic: " : "reply to "
  end

  desc %{
    Renders the body of the currently active post.
  }
  tag 'post:body' do |tag|
    raise TagError, "`post:body' tag requires that a post be present." unless tag.locals.post
    tag.locals.post.body_html
  end

  desc %{
    Renders the date of the current post
    strftime format as for page date tag
    
    *Usage:*
    <pre><code><r:post:date [format="%A, %B %d, %Y"] /></code></pre>
  }
  tag 'post:date' do |tag|
    raise TagError, "`post:date' tag requires that a post be present." unless tag.locals.post
    format = (tag.attr['format'] || '%A, %B %d, %Y')
    date = tag.locals.post.created_at
    adjust_time(date).strftime(format) 
  end

  desc %{
    Renders a link url for the currently active topic.
  }
  tag 'post:url' do |tag|
    raise TagError, "`post:url' tag requires that a post be present." unless tag.locals.post
    post = tag.locals.post
    "/forums/#{post.topic.forum.id}/topics/#{post.topic.id}?page_id=#{post.page}##{post.dom_id}"
  end

  desc %{
    Renders a link to the currently active post. Link text defaults to name of topic 
    so that calling @r:post:description@ immediately beforehand will produce a string that makes sense.
    All other attributes passed on to html <a> tag as usual

    *Usage:*
    <pre><code>
      <r:post:link />
      <r:post:link>read reply</r:post:link>
    </code></pre>

  }
  tag 'post:link' do |tag|
    raise TagError, "`post:link' tag requires that a post be present." unless tag.locals.post
    options = tag.attr.dup
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.locals.post.topic.title
    url = tag.render('post:url')
    %{<a href="#{url}"#{attributes}>#{text}</a>}
  end


  #### PAGES
  
  desc %{
    Puts the topic attached to this page in the foreground
    so that topic and post tags can be used to display page comments. 
    If no topic exists, it is because no comments have been posted 
    yet, so the tag will not expand.
     
    *Usage:*
    <pre><code>
      <r:comments>
        <r:posts:each>...</r:posts:each>
        <r:comments:form />
      </r:comments>
    </code></pre>
  }
  tag 'comments' do |tag|
    if tag.locals.page.topic
      tag.locals.topic = tag.locals.page.topic
      tag.expand
    end
  end

  desc %{
    A shortcut that returns all attached posts in standard page-comment form. 
    To enable page-comments all you need to do is put this in your layout:
     
    *Usage:*
    <pre><code>
      <r:comments:all />
      <r:comments:new_post />
    </code></pre>
  }
  tag 'comments:all' do |tag|
    raise TagError, "`comments:all' tag requires that a topic be present." unless tag.locals.topic
    results = []
    tag.locals.topic.posts.each do |post|
      tag.locals.post = post
      results << tag.render('comment')
    end
    results
  end

  desc %{
    A shortcut that displays the present post in a simple standard form. 
     
    *Usage:*
    <pre><code>
      <r:comments>
        <r:posts:each><r:comment /></r:posts:each>
      </r:comments>
    </code></pre>
  }
  tag 'comment' do |tag|
    raise TagError, "`comment' tag requires that a post be present." unless tag.locals.post
    tag.locals.user = tag.locals.post.user
    logger.warn "!!! post is #{tag.locals.post.id} and user is #{tag.locals.user.name}"
    %{
      <div class="comment" id="comment_#{tag.render('post:id')}">
        <h3>
          <a href="#{tag.render('user:url')}">#{tag.render('user:gravatar')} #{tag.render('user:name')}</a> 
          <span class="dated">on #{tag.render('post:date')}</span>
        </h3>
        #{tag.render('post:body')}
      </div>
    }
  end

  desc %{
    Renders a standard 'post a comment' link.
    This will take the user to the input form on the relevant topic
    page, which is a bit crappy but all we can do in the sessionless,
    cached world of the public site. For a better user experience, just 
    turn the link into an ajax call to its destination, which will 
    return a bare form suitable for dropping into the page.
    
    takes a class parameter and applies it to the link.
    if double, enclosed text or html becomes link contents

    Note that for all these page comment tags the page topic is not created
    until the post is posted.

    *Usage:*
    <pre><code>
      <r:comment_link class="get_comment_form" />
      <r:comment_link>say something</r:comment_link>
    </code></pre>
  }
  tag 'comment_link' do |tag|
    logger.warn "!!! comment_link"
    raise TagError, "`comment_link' tag requires that a page be present." unless tag.locals.page
    cssclass = tag.attr['class'] || 'get_form'
    text = tag.double? ? tag.expand : 'post a comment'
    %{<a href="/pages/#{tag.locals.page.id}/posts/new" class="#{cssclass}">#{text}</a>}
  end

  desc %{
    Renders a standard 'post a comment' form.
    Note that on posting the user will be returned to the same page
    (the cache will be cleared first) and that validation messages
    may appear in the form.
    You can supply id and class parameters for the table, and a label 
    parameter for the body field. Default there is 'add a comment'.
    
    You probably don't want to do this unless you know that everyone
    looking at this page is logged in: there's no way to tell from here
    and the page will be cached with the form on it.
    
    *Usage:*
    <pre><code><r:comment_form class="inlineform" /></code></pre>
  }
  tag 'comment_form' do |tag|
    raise TagError, "`comment_form' tag requires that a page be present." unless tag.locals.page
    domid = tag.attr['id'] || 'comment_form'
    cssclass = tag.attr['class'] || 'comment_form'
    label = tag.attr['label'] || 'Add a comment'
    %{
      <form action="/pages/#{tag.locals.page.id}/posts" method="post" class="#{cssclass}" id="#{domid}"> 
        <p>
          <label for="post_body">#{label}</label><br />
          <textarea name="post[body]" id="post_body" rows="10"></textarea><br />
          <input type="submit" value="Post comment" />
        </p>
      </form>
    }
  end

  desc %{
    Contained tags are rendered if the present page has comments.

    *Usage:*
    <pre><code><r:if_comments>...</r:if_comments></code></pre>
  }
  tag 'if_comments' do |tag|
    tag.expand if tag.locals.page && tag.locals.page.topic && tag.locals.page.topic.posts_count > 0
  end

  desc %{
    Contained tags are rendered unless the present page has comments.

    *Usage:*
    <pre><code><r:unless_comments>...</r:unless_comments></code></pre>
  }
  tag 'unless_comments' do |tag|
    tag.expand unless tag.locals.page && tag.locals.page.topic && tag.locals.page.topic.posts_count > 0
  end



  #### USERS


  desc %{
    root tag setting the forum owner object.
  }
  tag 'forum:user' do |tag|
    raise TagError, "`forum:user' tag requires that a forum be present." unless tag.locals.forum
    tag.locals.user = tag.locals.forum.user
    tag.expand
  end

  desc %{
    root tag setting the topic owner object
  }
  tag 'topic:user' do |tag|
    raise TagError, "`topic:user' tag requires that a topic be present." unless tag.locals.topic
    tag.locals.user = tag.locals.topic.user
    tag.expand
  end

  desc %{
    root tag setting the post owner object
  }
  tag 'post:user' do |tag|
    raise TagError, "`post:user' tag requires that a post be present." unless tag.locals.post
    tag.locals.user = tag.locals.post.user
    logger.warn "!!! post:user - tag.locals.user is #{tag.locals.user}"
    tag.expand
  end

  desc %{
    Inside this tag all tags refer to the first user matching the supplied title or login,
    if any, or else the user locally set by topic:user or forum:user
     
    *Usage:*
    <pre><code>
      <r:user name="Joe">...</r:user>
      <r:user login="Joe">...</r:user>
    </code></pre>
  }
  tag 'user' do |tag|
    unless tag.locals.user
      if tag.attr['name']
        tag.locals.user = User.find_by_name(tag.attr['name'])
      elsif tag.attr['login']
        tag.locals.user = User.find_by_login(tag.attr['name'])
      elsif tag.locals.page
        tag.locals.user = tag.locals.page.created_by
      end
    end
    raise TagError.new("no user!") unless tag.locals.user
    tag.expand
  end

  desc %{
    Renders the id of the currently active user.
  }
  tag 'user:id' do |tag|
    raise TagError, "`user:id' tag requires that a user be present." unless tag.locals.user
    tag.locals.user.id
  end

  desc %{
    Renders the name of the currently active user.
  }
  tag 'user:name' do |tag|
    raise TagError, "`user:name' tag requires that a user be present." unless tag.locals.user
    tag.locals.user.display_name
  end

  desc %{
    Renders a link url for the currently active user.
  }
  tag 'user:url' do |tag|
    raise TagError, "`user:url' tag requires that a user be present." unless tag.locals.user
    logger.warn "!!! in user:url user is #{tag.locals.user.name}"
    "/users/#{tag.locals.user.id}"
  end

  desc %{
    Renders the (htmlised version of the) description supplied by the currently active user.
  }
  tag 'user:description' do |tag|
    raise TagError, "`user:description' tag requires that a user be present." unless tag.locals.user
    tag.locals.user.body_html
  end

  desc %{
    Renders a gravatar image for the current user. Size and default parameters are passed through.

    *Usage:*
    <pre><code>
      <r:user:gravatar size="60" />
    </code></pre>
  }
  
  tag 'user:gravatar' do |tag|
    raise TagError, "`user:gravatar' tag requires that a user be present." unless tag.locals.user
    gravatar_options = { :size => tag.attr['size'] || 40 }
    gravatar_options[:default] = tag.attr['default'] if tag.attr['default']
    cssclass = tag.attr['class'] || 'gravatar'
    url = tag.locals.user.gravatar_url(gravatar_options)
    %{<img src="#{url}" width="#{gravatar_options[:size]}" height="#{gravatar_options[:size]}" class="#{cssclass}" alt="gravatar for #{tag.locals.user.name}" />}
  end

  desc %{
    Renders a link to the currently active user. Link text defaults to name of user.
    All other attributes passed on to html <a> tag (exactly as for page links).

    *Usage:*
    <pre><code>
      <r:user:link class="heavy" />
      <r:user:link><r:user:gravatar size="32" /></r:user:link>
    </code></pre>

  }
  tag 'user:link' do |tag|
    raise TagError, "`user:link' tag requires that a user be present." unless tag.locals.user
    logger.warn "!!! user:link - tag.locals.user is #{tag.locals.user}"
    options = tag.attr.dup
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.render('user:name')
    url = tag.render('user:url')
    %{<a href="#{url}" class="#{options['class']}">#{text}</a>}
  end





  #### USEFUL

  desc %{
    Renders contents if current user is logged in
    
    *Usage:*
    <pre><code><r:if_logged_in />...</r:if_logged_in></code></pre>
  }
  tag 'if_logged_in' do |tag|
    tag.expand if UserActionObserver.current_user
  end

  desc %{
    Renders contents unless current user is logged in
    
    *Usage:*
    <pre><code><r:unless_logged_in />...</r:unless_logged_in></code></pre>
  }
  tag 'unless_logged_in' do |tag|
    tag.expand unless UserActionObserver.current_user
  end


  private
  
  # remember this is going to be an instance method of Page
  
  def forums_find_options(tag, model=Forum)
    attr = tag.attr.symbolize_keys
    
    options = {}
    
    [:limit, :offset].each do |symbol|
      if number = attr[symbol]
        if number =~ /^\d{1,4}$/
          options[symbol] = number.to_i
        else
          raise TagError.new("`#{symbol}' attribute of `each' tag must be a positive number between 1 and 4 digits")
        end
      end
    end
    
    by = (attr[:by] || 'created_at').strip
    order = (attr[:order] || 'asc').strip
    order_string = ''
    if model.column_names.include?(by)
      order_string << by
    else
      raise TagError.new("`by' attribute of `each' tag must be set to a valid field name")
    end
    if order =~ /^(asc|desc)$/i
      order_string << " #{$1.upcase}"
    else
      raise TagError.new(%{`order' attribute of `each' tag must be set to either "asc" or "desc"})
    end
    options[:order] = order_string
    
    options
  end
  
  # you are going to do this properly at some point, aren't you?
  
  def forum_url(forum)
    "/forums/#{forum.id}"
  end


end
