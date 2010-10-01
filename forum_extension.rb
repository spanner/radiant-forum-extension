require_dependency 'application_controller'

class ForumExtension < Radiant::Extension
  version "0.4"
  description "Nice clean forums and page comments for inclusion in your radiant site. Derived long ago from beast. Requires the reader extension and share_layouts."
  url "http://spanner.org/radiant/forum"

  def activate
    Reader.send :include, ForumReader
    ReaderNotifier.send :include, ForumReaderNotifier
    ReadersController.send :include, ForumReadersController
    Page.send :include, ForumPage
    UserActionObserver.instance.send :add_observer!, Forum
    UserActionObserver.instance.send :add_observer!, Topic
    UserActionObserver.instance.send :add_observer!, Post
    Page.send :include, ForumTags
    Admin::ReaderSettingsController.make_settable 'forum.editable_period' => 15, 'forum.public?' => true, 'forum.layout' => '', 'forum.allow_page_comments?' => true
    
    unless defined? admin.forum # UI is a singleton
      Radiant::AdminUI.send :include, ForumAdminUI
      admin.forum = Radiant::AdminUI.load_default_forum_regions
      admin.pages.edit.add :parts_bottom, "edit_commentability", :after => "edit_layout_and_type"
      admin.reader_settings.index.add :settings, "forum", :after => "sender"
      if defined? Site && admin.sites
        Site.send :include, ForumSite
      end
    end
    
    if defined? RedCloth::DEFAULT_RULES     # identifies redcloth 3
      RedCloth.send :include, ForumRedCloth3
      RedCloth::DEFAULT_RULES.push(:smilies)
    else
      RedCloth::TextileDoc.send :include, ForumRedCloth4
    end
    
    ApplicationHelper.send :include, ForumHelper

    tab("Readers") do
      add_item 'Forum', '/admin/readers/forums', :before => 'Settings'
    end
  end
  
end

