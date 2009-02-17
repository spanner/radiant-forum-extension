require_dependency 'application'
gem 'mislav-will_paginate', '~> 2.2'
require 'will_paginate'

class ForumExtension < Radiant::Extension
  version "0.2"
  description "Simple forums and page comments for inclusion in your radiant site. Derived long ago from beast. Requires the reader extension and share_layouts."
  url "http://spanner.org/radiant/forum"

  define_routes do |map|
    map.resources :forums do |forum|
      forum.resources :topics, :name_prefix => nil do |topic|
        topic.resources :posts, :name_prefix => nil
        topic.resource :monitorship, :controller => :monitorships, :name_prefix => nil
      end
    end

    %w(user forum).each do |attr|
      map.resources :posts, :name_prefix => "#{attr}_", :path_prefix => "/#{attr.pluralize}/:#{attr}_id"
    end

    map.with_options :controller => 'posts' do |page|
      page.resources :posts, :path_prefix => '/pages/:page_id', :name_prefix => 'page_'
    end

    map.resources :posts, :name_prefix => 'all_', :collection => { :search => :get }

    map.namespace :admin do |admin|
      admin.resources :forums
    end

  end
  
  def activate
    Forum; Topic; Post
    Reader.send :include, ForumReader
    ReaderNotifier.send :include, ForumReaderNotifier
    Page.send :include, ForumPage
    Page.send :include, ForumTags
    Radiant::AdminUI.send :include, ForumAdminUI
    Radiant::AdminUI.instance.forum = Radiant::AdminUI.load_default_forum_regions
    ApplicationHelper.module_eval { include ForumHelper }
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag| 
      "<span class='field_error'>#{html_tag}</span>" 
    end 

    admin.tabs.add "Forum", "/admin/forums", :after => "Readers", :visibility => [:all]
  end
  
  def deactivate
    admin.tabs.remove "Forum"
  end
  
end