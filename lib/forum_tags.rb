module ForumTags
  include Radiant::Taggable
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  
  class TagError < StandardError; end

  tag 'comments' do |tag|
    raise TagError, "can't have comments without a page" unless page = tag.locals.page
    if page.commentable?
      tag.locals.comments = page.posts
      tag.expand
    end
  end

  desc %{
    Returns a string in the form "x comments" or "no comments yet".
  
    *Usage:*
    <pre><code><r:comments:summary /></code></pre>
  }
  
  tag 'comments:summary' do |tag|
    if tag.locals.comments.empty?
      "no comments yet"
    elsif tag.locals.comments.size == 1
      "one comment"
    else
      "#{tag.locals.comments.size} comments"
    end
  end

  desc %{
    Anything between if_comments tags is displayed only - dramatic pause - if there are comments.
  
    *Usage:*
    <pre><code><r:if_comments>...</r:if_comments></code></pre>
  }
  tag 'if_comments' do |tag|
    raise TagError, "can't have if_comments without a page" unless page = tag.locals.page
    tag.expand if page.posts.any?
  end

  desc %{
    Anything between unless_comments tags is displayed only if there are no comments.
  
    *Usage:*
    <pre><code><r:unless_comments>...</r:unless_comments></code></pre>
  }
  tag 'unless_comments' do |tag|
    raise TagError, "can't have unless_comments without a page" unless page = tag.locals.page
    tag.expand if page.posts.any?
  end
  
  desc %{
    If you want more control over the display of page comments, you can spell them out:
  
    *Usage:*
    <pre><code><r:comments:each>
      <h2><r:comment:reader:name /></h2>
      <p class="date"><r:comment:date /></p>
      <r:comment:body_html />
    </r:comments:each>
    <r:comment_link />
    </code></pre>
  }
  tag 'comments:each' do |tag|
    results = []
    tag.locals.comments.each do |post|
      tag.locals.comment = post
      results << tag.expand
    end
    results
  end
  
  desc %{
    To enable page commenting, all you have to do is put this in your layout:
  
    *Usage:*
    <pre><code><r:comments:all /></code></pre>
  }
  tag 'comments:all' do |tag|
    posts = tag.locals.comments
    results = ""
    results << %{<div class="page_comments">}
    results << "<h2>Comments</h2>"
    results << %{<div id="forum">
}
    if posts.empty?
      results << "<p>None yet.</p>"
    else
      posts.each do |post|
        tag.locals.comment = post
        results << tag.render('comment')
      end
    end
    results << %{#{tag.render('comment_link', 'class' => 'inline inviting')}}
    results << "</div></div>"
    results
  end

  tag 'comment' do |tag|
    raise TagError, "can't have r:comment without a post" unless post = tag.locals.comment
    if tag.double?
      tag.locals.reader = post.reader
      tag.expand
    else
      %{<div class="post" id="#{post.dom_id}">
  <div class="post_header">
    <h2><img src="#{post.reader.gravatar_url(:size => 40)}" width="40" height ="40" class="gravatar" /> #{post.reader.name}</h2>
    <p class="context">#{friendly_date(post.created_at)}</p>
  </div>
  <div class="post_body">#{post.body_html}</div>
</div>}
    end
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
      <r:if_comments>
        <r:comment_link />
      </r:if_comments>
      <r:unless_comments>
        <r:comment_link class="how_exciting">Be the first to add a comment!</r:comment_link>
      </r:unless_comments>
    </code></pre>
  }
  tag 'comment_link' do |tag|
    raise TagError, "can't have `r:comment_link' without a page." unless tag.locals.page
    options = tag.attr.dup
    options['class'] ||= 'newmessage'
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.to_s.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : "Add a comment"
    %{<a href="#{tag.render('comment_url')}"#{attributes}>#{text}</a>}
  end

  desc %{
    The address for add-a-comment links
  }
  tag 'comment_url' do |tag|
    raise TagError, "can't have `r:comment_url' without a page." unless tag.locals.page
    new_page_post_url(tag.locals.page)
  end

  desc %{
    Shows the standard block of recent discussion activity.
  }
  tag 'forum_latest' do |tag|
    results = []
    results << %{<ul class="clean">}
    Topic.visible.latest(6).each do |topic|
      tag.locals.topic = topic
      results << %{<li>#{tag.render('topic:summary')}</li>}
    end
    results << %{</ul>}
    results
  end

  desc %{
    Shows the standard forum search form in a reasonably compact and stylable way. 
    
    Takes options with_title (set to false to omit the usual heading), by_forum (set to true to show a discussion category dropdown) and by_reader (set to true to show a message-from dropdown) and label (set to the title you would like to display over the main search field).
  }
  tag 'forum_search' do |tag|
    results = []
    compact = true unless tag.attr['by_forum'] == 'true' || tag.attr['by_reader'] == 'true' 
    q_label = tag.attr['label']
    q_label = "Look for this text" if q_label.blank? && !compact
    results << %{<form class="friendly" action="#{search_posts_url}">}
    results << %{<h2>Forum Search</h2>} unless tag.attr['with_title'] == 'false'
    results << %{<p>}
    results << %{<label for="q">#{q_label}</label><br />} unless q_label.blank?
    results << %{#{text_field_tag("q", params[:q], :class => 'standard')}}
    results << %{#{submit_tag "search", :class => 'button'}} if compact
    results << %{</p>}
    unless compact
      results << %{<p><label for="reader_id">From this person</label><br /><select name="reader_id"><option value="">anyone</option>#{options_from_collection_for_select(Reader.all, "id", "name")}</select></p>} if tag.attr['by_reader'] == 'true'
      results << %{<p><label for="forum_id">In this discussion category</label><br /><select name="forum_id"><option value="">anywhere</option>#{options_from_collection_for_select(Forum.visible, "id", "name")}</select></p>} if tag.attr['by_forum'] == 'true'
      results << %{<p class="buttons">#{submit_tag "search", :class => 'button'}</p>} 
    end
    results << %{</form>}
    results
  end

  tag 'topic' do |tag|
    tag.expand if tag.locals.topic
  end
  tag 'topic:summary' do |tag|
    results = []
    topic = tag.locals.topic
    post = topic.last_post
    results << %{<img src="#{post.reader.gravatar_url(:size => 42)}" width="42" height="42" class="gravatar"> } if tag.attr['gravatar'] == 'true'
    results << %{<a href="#{forum_topic_path(topic.forum, topic)}">#{topic.name}</a> }
    results << %{<span class="credit">}
    if topic.page
      results << " commented upon by "
    elsif post.first?
      results << " started by "
    else
      results << " replied to by "
    end
    results << "#{post.reader.name} #{friendly_date(post.created_at)}"
    results << %{</span>}
    results
  end



private

  # copied from forum_helper
  
  def friendly_date(datetime)
    if datetime
      date = datetime.to_date
      if (date == Date.today)
        format = "today at %l:%M%p"
      elsif (date == Date.yesterday)
        format = "yesterday at %l:%M%p"
      elsif (date.year == Date.today.year)
        format = "on %B %e"
      else
        format = "on %B %e, %Y"
      end
      datetime.strftime(format)
    end
  end

end
