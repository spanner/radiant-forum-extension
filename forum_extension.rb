require_dependency 'application_controller'
require 'will_paginate'

class ForumExtension < Radiant::Extension
  version "0.4"
  description "Nice clean forums and page comments for inclusion in your radiant site. Derived long ago from beast. Requires the reader extension and share_layouts."
  url "http://spanner.org/radiant/forum"

  define_routes do |map|
    
    map.with_options :path_prefix => '/forum' do |forum|
      forum.resources :forums, :only => [:index, :show], :has_many => [:topics, :posts]
      forum.resources :topics, :has_many => [:posts]
      forum.resources :posts, :collection => {:search => :get, :monitored => :get}
      forum.resources :pages, :has_many => [:posts], :has_one => [:topic]
    end
    
    
    # forum admin is nested under readers to save interface clutter
    # some time soon I'll add proper moderation of topics and posts
    map.namespace :admin, :member => { :remove => :get }, :path_prefix => 'admin/readers' do |admin|
      admin.resources :forums
      # admin.resources :topics
      # admin.resources :posts
    end
        
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
    
    unless defined? admin.forum # UI is a singleton and already loaded
      Radiant::AdminUI.send :include, ForumAdminUI
      admin.forum = Radiant::AdminUI.load_default_forum_regions
      admin.pages.edit.add :parts_bottom, "edit_commentability", :after => "edit_layout_and_type"
      if defined? Site && admin.sites       # currently we know it's the spanner multi_site if admin.sites is defined
        Site.send :include, ForumSite
        admin.sites.edit.add :form, "admin/sites/choose_forum_layout", :after => "edit_homepage"
      end
    end
    
    if defined? RedCloth::DEFAULT_RULES
      RedCloth.send :include, ForumRedCloth3
      RedCloth::DEFAULT_RULES.push(:smilies)
    else
      RedCloth::TextileDoc.send :include, ForumRedCloth4
    end
    
    ApplicationHelper.send :include, ForumHelper

    if defined? ActiveRecord::SiteNotFound
      admin.forums.index.add :top, "admin/shared/site_jumper"
    end
    admin.tabs['Readers'].add_link('forum admin', '/admin/readers/forums')
  end
  
  def deactivate
    admin.tabs.remove "Forum"
  end
  
end

