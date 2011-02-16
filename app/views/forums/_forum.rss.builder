xm.item do
  suffix = 
  xm.title h("#{forum.name}")
  xm.description forum.description
  xm.pubDate forum.created_at.to_s(:rfc822)
  xm.guid [ActionController::Base.session_options[:session_key], forum.id.to_s].join(":"), "isPermaLink" => "false"
  xm.link forum_url(forum)
end
