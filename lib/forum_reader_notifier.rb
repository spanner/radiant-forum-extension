module ForumReaderNotifier

  def post(reader, post)
    setup_email(reader)
    @subject += "New post under '#{post.topic.name}'"
    @body[:post] = post
    @body[:post_url] = url_for(post)
  end
end
