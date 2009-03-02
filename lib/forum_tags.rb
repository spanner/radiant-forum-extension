module ForumTags
  include Radiant::Taggable
  
  class TagError < StandardError; end

  # there used to be logs of forum/topic/post tags here but the page caching makes them a bit unhelpful
  # page comments are ok, though: the commenting mechanism uncaches the page when they're created

  desc %{
    Brings the comments partial into a page by way of Chris Parrish's parse_template subterfuge.
    To enable page commenting, all you have to do is put this in your layout:
  
    *Usage:*
    <pre><code><r:page:comments /></code></pre>
  }
  tag 'page:comments' do |tag|
    raise TagError("can't have page:comments without a page") unless page = tag.locals.page
    posts = page.posts
    results = []
    results << "<h2>Comments</h2>"
    if posts.empty?
      results << "<p>None yet.</p>"
    else
      results << %{<div id="forum">}
      posts.each do |post|
        tag.locals.post = post
        results << tag.render('comment')
      end
      results << %{<h3><a href="/pages/#{page.id}/posts/new">Add a comment</a></h3>}
      results << "</div>"
    end
    results
  end

  tag 'page:comment' do |tag|
    raise TagError("can't have page:comment without a post") unless post = tag.locals.post
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
    
    # parse_template 'pages/_comment', {
    #   :page => tag.locals.page,
    #   :post => tag.locals.post
    # }
  end

  private

    def parse_template(filename, locals = {})
      require 'haml/engine'
      haml_engine = Haml::Engine.new(File.read("#{ForumExtension.root}/app/views/" + filename + '.html.haml'))
      haml_engine.to_html(Object.new, locals)
    end

end
