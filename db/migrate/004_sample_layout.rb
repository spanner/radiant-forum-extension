class SampleLayout < ActiveRecord::Migration
  def self.up
    Layout.reset_column_information
    Layout.create :name => 'forum_example', :content => <<-EO
    <!DOCTYPE html>
    <html>
      <head>
        <title>Forum : <r:title /></title>
        <link rel="stylesheet" href="/stylesheets/forum.css" type="text/css" media="all" />
        <script src="http://code.jquery.com/jquery-1.5.js" type="text/javascript"></script>
      </head>
      <body>
        <div id="container">
          <div id="header">
            <r:content part="controls" />
            <h1>
              <r:content part="breadhead" />
              <r:title />
            </h1>
            <r:content part="signals" />
          </div>
          <div id="marginalia">
            <r:content part="sidebar" />
          </div>
          <div id="page">
            <r:content />
          </div>
        </div>
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
