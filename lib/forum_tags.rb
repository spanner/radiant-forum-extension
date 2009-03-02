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
    raise TagError("can't have comments without a page") unless tag.locals.page
    posts = tag.locals.page.posts
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
      results << %{<h3><a href="/pages/#{tag.locals.page.id}/posts/new">Add a comment</a></h3>}
      results << "</div>"
    end
    results
  end

  tag 'page:comment' do |tag|
    raise TagError("can't have comment without a post") unless tag.locals.post
    parse_template 'pages/_comment', {
      :page => tag.locals.page,
      :post => tag.locals.post
    }
  end

  private

    def parse_template(filename, locals = {})
      require 'haml/engine'
      haml_engine = Haml::Engine.new(File.read("#{ForumExtension.root}/app/views/" + filename + '.html.haml'))
      haml_engine.to_html(Object.new, locals)
    end

end
