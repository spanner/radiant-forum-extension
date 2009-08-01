# app/views/layouts/application.rss.builder
xml.instruct! :xml, :version => '1.0' 
xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml << yield
end