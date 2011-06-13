class SampleLayout < ActiveRecord::Migration
  def self.up
    Layout.reset_column_information
    Layout.create :name => 'forum_example', :content => <<-EO
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
      "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
  <head>
    <title>Forum : <r:content part="pagetitle" /></title>
    <link rel="stylesheet" href="/stylesheets/forum_demo.css" type="text/css" media="all" />
    <script src="http://code.jquery.com/jquery-1.5.js" type="text/javascript"></script>
  </head>
  <body>
    <div id="container">
      <div id="header">
        <div id="masthead">
          <div id="search"><r:content part="search" /></div>
          <p id="sitetitle"><a href="/"><span class="logo">☆</span> Radiant Forum</a></p>
          <p id="navigation">
            <r:navigation paths="home: / | installation: /install | documentation: /docs | demo: /forum">
              <r:normal><a href="<r:path />"><r:title /></r:normal>
              <r:selected><a href="<r:path />" class="here"><r:title /></r:selected>
            </r:navigation>
            <a href="https://github.com/spanner/radiant-forum-extension">code</a>
            <a href="https://github.com/spanner/radiant-forum-extension/issues">issues</a>
          </p>
        </div>
      </div>
      <div id="page">
        <h1 class="title">
          <span class="breadhead"><r:content part="breadhead" /></span>
          <r:title />
        </h1>
        <r:content part="signals" />
        <div id="marginalia">
          <r:content part="sidebar" />
        </div>
        <div id="main">
          <r:if_content part="introduction">
            <div id="introduction"><r:content part="introduction" /></div>
          </r:if_content>
          <r:content />
        </div>
      </div>
      <div id="footer">
        <div id="colophon">
          <r:content part="controls" />
          <r:content part="section_navigation" />
        </div>
      </div>
    </div>

    <r:content part="reader_js" />
    <r:content part="forum_js" />
    <r:content part="toolbar_js" />
  </body>
</html>
    EO
    Radiant::Config['forum.layout'] = 'forum_example'
  end

  def self.down
  end
end
