xm.item do
  suffix = topic.last_post == topic.first_post ? ": new topic from #{topic.reader.name}" : ": reply from #{topic.reader.name}"
  xm.title h(topic.name + suffix)
  xm.description truncate_words(topic.posts.first.body, 64)
  xm.pubDate topic.created_at.rfc822
  xm.guid [request.host_with_port+request.relative_url_root, topic.forum_id.to_s, topic.id.to_s].join(":"), "isPermaLink" => "false"
  xm.author h(topic.reader.name)
  xm.link topic_url(topic.forum, topic)
end
