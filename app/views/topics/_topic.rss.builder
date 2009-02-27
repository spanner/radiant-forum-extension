xm.item do
  xm.title h(topic.name)
  xm.description truncate_words(topic.posts.first.body, 64)
  xm.pubDate topic.created_at.rfc822
  xm.guid [request.host_with_port+request.relative_url_root, topic.forum_id.to_s, topic.id.to_s].join(":"), "isPermaLink" => "false"
  xm.author "#{topic.reader.name}"
  xm.link topic_url(topic.forum, topic)
end
