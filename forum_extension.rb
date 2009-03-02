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
        topic.resources :posts, :name_prefix => nil, :collection => 'preview'
        topic.resource :monitorship, :controller => :monitorships, :name_prefix => nil
      end
    end
    
    map.namespace :admin do |admin|
      admin.resources :forums
    end

    %w(reader forum page).each do |attr|
      map.resources :posts, :name_prefix => "#{attr}_", :path_prefix => "/#{attr.pluralize}/:#{attr}_id", :collection => 'preview'
    end

    map.with_options :controller => 'topics' do |topics|
      topics.topics_list '/topics', :action => 'index'
    end

    map.with_options :controller => 'posts' do |posts|
      posts.posts_list '/posts', :action => 'index'
    end

  end
  
  def activate
    Forum; Topic; Post
    Reader.send :include, ForumReader
    ReaderNotifier.send :include, ForumReaderNotifier
    ReadersController.send :include, ForumReadersController
    Page.send :include, ForumPage
    Page.send :include, ForumTags
    Site.send :include, ForumSite
    RedCloth.send :include, ForumRedCloth
    ApplicationHelper.send :include, ForumHelper
    ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
      :human_date => %{<span class="date">%e %b %Y</span> at <span class="time">%l:%M</span><span class="meridian">%p</span>}
    )

    admin.tabs.add "Forum", "/admin/forums", :after => "Readers", :visibility => [:all]
  end
  
  def deactivate
    admin.tabs.remove "Forum"
  end
  
end

