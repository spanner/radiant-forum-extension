class SampleLayout < ActiveRecord::Migration
  def self.up
    Layout.reset_column_information
    Layout.create :name => 'forum_example', :content => <<-EO
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
  <head>
    <title>Forum : <r:content part="pagetitle" /></title>
    <link rel="stylesheet" href="/stylesheets/platform/reader.css" type="text/css" media="all" />
    <link rel="stylesheet" href="/stylesheets/platform/forum.css" type="text/css" media="all" />
    <script type="text/javascript" charset="utf-8" src="/javascripts/platform/mootools.js"></script>
    <script type="text/javascript" charset="utf-8" src="/javascripts/platform/core.js"></script>
    <script type="text/javascript" charset="utf-8" src="/javascripts/platform/forum.js"></script>
    <script type="text/javascript" charset="utf-8" src="/javascripts/platform/remotecontent.js"></script>
  </head>
  <body>
    <div id="container">
      <div id="header">
        <h1>
          <r:content part="breadhead" />
          <r:content part="pagetitle" />
          <r:content part="feed" />
        </h1>
      </div>
      <div id="page">
        <r:content />
      </div>
      <div id="footer">
        <r:content part="controls" />
      </div>
    </div>
  </body>
</html>
    EO
    Radiant::Config['forum.layout'] = 'forum_example'
  end

  def self.down
  end
end
