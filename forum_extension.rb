require_dependency 'application_controller'

class ForumExtension < Radiant::Extension
  version "1.1.2"
  description "Nice clean forums and page comments for inclusion in your radiant site. Derived long ago from beast. Requires the reader extension and share_layouts."
  url "http://spanner.org/radiant/forum"

  extension_config do |config|
    config.gem "paperclip"
  end

  def activate
    Reader.send :include, ForumReader
    ReaderNotifier.send :include, ForumReaderNotifier
    ReadersController.send :include, ForumReadersController
    Page.send :include, ForumPage
    UserActionObserver.instance.send :add_observer!, Forum
    UserActionObserver.instance.send :add_observer!, Topic
    UserActionObserver.instance.send :add_observer!, Post
    Page.send :include, ForumTags
    
    unless defined? admin.forum # UI is a singleton
      Radiant::AdminUI.send :include, ForumAdminUI
      admin.forum = Radiant::AdminUI.load_default_forum_regions
    end
    
    # admin.pages.edit.add :parts_bottom, "edit_commentability", :after => "edit_layout_and_type"
    admin.reader_configuration.show.add :settings, "forum", :after => "administration"
    admin.reader_configuration.edit.add :form, "edit_forum", :after => "administration"
    
    if defined? Site && admin.sites
      Site.send :include, ForumSite
    end
    
    if defined? RedCloth::DEFAULT_RULES     # identifies redcloth 3
      RedCloth.send :include, ForumRedCloth3
      RedCloth::DEFAULT_RULES.push(:smilies)
    else
      RedCloth::TextileDoc.send :include, ForumRedCloth4
    end

    tab("Forum") do
      add_item 'Categories', '/admin/forum/forums'
      add_item 'Topics', '/admin/forum/topics'
      add_item 'Posts', '/admin/forum/posts'
      add_item 'Settings', '/admin/forum/settings'
    end
  end
  
end

