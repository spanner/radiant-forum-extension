module ForumTags
  include Radiant::Taggable
  
  class TagError < StandardError; end

  desc %{
    To enable page commenting, all you have to do is put this in your layout:
  
    *Usage:*
    <pre><code><r:page:comments:all /></code></pre>
    
    In order that pages can still be cached, we show a reply link rather than a form. The sample
    javascript library included with the forum extension will turn this into a login or comment
    form as appropriate.
  }
  tag 'page:comments' do |tag|
    raise TagError, "can't have page:comments without a page" unless page = tag.locals.page
    tag.locals.comments = page.posts
    tag.expand
  end
  
  tag 'page:comments:all' do |tag|
    posts = tag.locals.comments
    results = []
    results << "<h2>Comments</h2>"
    results << %{<div id="forum">}
    if posts.empty?
      results << "<p>None yet.</p>"
    else
      posts.each do |post|
        tag.locals.comment = post
        results << tag.render('comment')
      end
    end
    results << %{<h3><a href="/pages/#{tag.locals.page.id}/posts/new" class="comment_link">Add a comment</a></h3>}
    results << "</div>"
    results
  end

  tag 'page:comment' do |tag|
    raise TagError, "can't have page:comment without a post" unless post = tag.locals.comment
    results = []
    results << %{
<div class="post" id="#{post.dom_id}>"
  <div class = "post_header">
    <h2>
      <a href="#{reader_url(post.reader)}" class="main">
        <img src="#{post.reader.gravatar_url(:size => 40)}" width="40" height ="40" class="gravatar" />
        #{post.reader.name}
      </a>
    </h2>
    <p class="context">#{post.date_html}</p>
  </div>
  <div class = "post_body">#{post.body_html}</div>
</div>
    }
  end

  desc %{
    If you want more control over the display of page comments, you can spell them out:
  
    *Usage:*
    <pre><code><r:page:comments:each>
      <h2><r:comment:reader:name /></h2>
      <p class="date"><r:comment:date /></p>
      <r:comment:body_html />
    </r:page:comments:each>
    <r:page:comment_link />
    </code></pre>
  }
  tag 'page:comments:each' do |tag|
    results = []
    tag.locals.comments.each do |post|
      tag.locals.comment = post
      results << tag.expand
    end
    results
  end

  tag 'comment' do |tag|
    raise TagError, "comment is not defined" unless tag.locals.comment
    tag.locals.reader = tag.locals.comment.reader
    tag.expand
  end
  tag 'comment:reader' do |tag|
    raise TagError, "can't have comment:reader without a comment" unless reader = tag.locals.reader
    tag.expand
  end

  desc %{
    The name of the commenter
  }
  tag 'comment:reader:name' do |tag|
    tag.locals.reader.name
  end
  
  desc %{
    A gravatar for the commenter
  }
  tag 'comment:reader:gravatar' do |tag|
    tag.locals.reader.gravatar
  end

  desc %{
    The date of the comment
  }
  tag 'comment:date' do |tag|
    tag.locals.comment.created_at.to_s(:html_date)
  end

  desc %{
    The time_ago of the comment
  }
  tag 'comment:ago' do |tag|
    time_ago_in_words(tag.locals.comment.created_at)
  end

  desc %{
    The body of the comment as it was entered (but html-escaped)
  }
  tag 'comment:body' do |tag|
    h(tag.locals.comment.body)
  end

  desc %{
    The body of the comment rendered into html (and whitelisted, so this ought to be safe)
  }
  tag 'comment:body_html' do |tag|
    tag.locals.comment.body_html
  end

  desc %{
    A link to the post-a-comment form. Typically you'll use a bit of remote scripting to replace this with
    a comment or login form depending on whether a reader is detected, but you can just leave the link too.
    
    If text is given, the link will be wrapped around it. The default is just "Add a comment". Any supplied 
    attributes are passed through, so you can specify class, id and anything else you like.

    *Usage:*
    <pre><code>
      <r:page:if_comments>
        <r:page:comment_link />
      </r:page:if_comments>
      <r:page:unless_comments>
        <r:page:comment_link class="how_exciting">Be the first to add a comment!</r:page:comment_link>
      </r:page:unless_comments>
    </code></pre>
  }
  tag 'page:comment_link' do |tag|
    raise TagError, "can't have `page:comment_link' without a page." unless tag.locals.page
    options = tag.attr.dup
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : "Add a comment"
    %{<a href="#{tag.render('page:comment_url')}"#{attributes}>#{text}</a>}
  end

  desc %{
    The address for add-a-comment links
  }
  tag 'page:comment_url' do |tag|
    raise TagError, "can't have `page:comment_url' without a page." unless tag.locals.page
    new_page_post_url(tag.locals.page)
  end

end
