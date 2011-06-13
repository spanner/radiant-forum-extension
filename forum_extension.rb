require_dependency 'application_controller'
require 'radiant-forum-extension/version'

class ForumExtension < Radiant::Extension
  version RadiantForumExtension::VERSION
  description "Nice clean forums and page comments for inclusion in your radiant site."
  url "http://spanner.org/radiant/forum"

  def activate
    ActiveRecord::Base.send :include, CommentableModel                         # provides has_comments class method that is used here by topics and pages but can be called from any model
    Reader.send :include, ForumReader                                          # has topics and posts
    ReaderNotifier.send :include, ForumReaderNotifier                          # sets up post-notification email
    Page.send :include, ForumPage                                              # makes commentable and reads some configuration
    Page.send :include, ForumTags                                              # defines radius tags for highlighting forum content on other pages
    ReadersController.send :include, ForumReadersController                    # adds some partials and helpers to the reader pages
    ReaderSessionsController.send :include, ForumReaderSessionsController      # changes default login destination to the forum front page
    
    unless defined? admin.forum # UI is a singleton
      Radiant::AdminUI.send :include, ForumAdminUI
      Radiant::AdminUI.load_forum_extension_regions
    end
    
    admin.pages.edit.add :parts_bottom, "edit_commentability", :after => "edit_layout_and_type"
    admin.reader_configuration.show.add :settings, "forum", :after => "administration"
    admin.reader_configuration.edit.add :form, "edit_forum", :after => "administration"
    
    if defined? RedCloth::DEFAULT_RULES
      RedCloth.send :include, ForumRedCloth3
      RedCloth::DEFAULT_RULES.push(:smilies)
    else
      RedCloth::TextileDoc.send :include, ForumRedCloth4
    end

    tab("Forum") do
      add_item 'Topics', '/admin/forum/topics'
      add_item 'Categories', '/admin/forum/forums'
      add_item 'Posts', '/admin/forum/posts'
      add_item 'Settings', '/admin/readers/reader_configuration'
    end
  end
  
end
