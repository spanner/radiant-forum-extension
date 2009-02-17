xm.item do
  xm.title "#{h(topic.title)} posted by #{h(topic.user.display_name)}"
  xm.description topic.posts.first.body_html
  xm.pubDate topic.created_at.rfc822
  xm.guid [request.host_with_port+request.relative_url_root, topic.forum_id.to_s, topic.id.to_s].join(":"), "isPermaLink" => "false"
  xm.author "#{topic.user.display_name}"
  xm.link topic_url(topic.forum, topic)
end
