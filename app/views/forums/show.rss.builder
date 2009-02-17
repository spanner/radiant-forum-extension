xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

xml.rss "version" => "2.0",
  'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:atom'       => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "#{Radiant::Config['forum.site_title']} : #{@forum.name}"
    xml.link forum_url(@forum)
    xml.language "en-us"
    xml.ttl "60"
    render :partial => "topics/topic", :collection => @topics, :locals => {:xm => xml}
  end
end
