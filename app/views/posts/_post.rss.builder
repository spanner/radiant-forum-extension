xm.item do
  prefix = post == post.topic.posts.first ? "new topic:" : "reply posted to"
  xm.title "#{prefix} #{h(post.respond_to?(:topic_title) ? post.topic_title : post.topic.title)}"
  xm.description post.body_html
  xm.pubDate post.created_at.rfc822
  xm.guid [request.host_with_port+request.relative_url_root, post.forum_id.to_s, post.topic_id.to_s, post.id.to_s].join(":"), "isPermaLink" => "false"
  xm.author "#{post.user.display_name}"
  xm.link topic_url(post.forum_id, post.topic_id)
end
