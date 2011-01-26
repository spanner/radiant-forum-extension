require_dependency 'application_controller'

class ForumExtension < Radiant::Extension
  version "2.0.0"
  description "Nice clean forums and page comments for inclusion in your radiant site. Derived long ago from beast. Requires the reader extension and share_layouts."
  url "http://spanner.org/radiant/forum"

  extension_config do |config|
    config.gem "paperclip", "~> 2.3"
  end

  def activate
    Reader.send :include, ForumReader                                          # has topics and posts
    ReaderNotifier.send :include, ForumReaderNotifier                          # sets up post-notification email
    Page.send :include, ForumPage                                              # topic association and comment support
    Page.send :include, ForumTags                                              # radius tags for highlighting forum content on other pages
    ReadersController.send :include, ForumReadersController
    ReaderSessionsController.send :include, ForumReaderSessionsController
    
    unless defined? admin.forum # UI is a singleton
      Radiant::AdminUI.send :include, ForumAdminUI
      Radiant::AdminUI.load_forum_extension_regions
    end
    
    # admin.pages.edit.add :parts_bottom, "edit_commentability", :after => "edit_layout_and_type"
    admin.reader_configuration.show.add :settings, "forum", :after => "administration"
    admin.reader_configuration.edit.add :form, "edit_forum", :after => "administration"
    
    if defined? RedCloth::DEFAULT_RULES
      RedCloth.send :include, ForumRedCloth3
      RedCloth::DEFAULT_RULES.push(:smilies)
    else
      RedCloth::TextileDoc.send :include, ForumRedCloth4
    end

    tab("Forum") do
      add_item 'Categories', '/admin/forum/forums'
      add_item 'Topics', '/admin/forum/topics'
      add_item 'Posts', '/admin/forum/posts'
      add_item 'Settings', '/admin/reader_configuration'
    end
  end
  
end