forum_prefix = Radiant.config['forum.path'] || "/forum"

ActionController::Routing::Routes.draw do |map|
  map.with_options :path_prefix => forum_prefix do |forum|
    forum.resources :forums, :only => [:index, :show], :has_many => [:topics]
    forum.resources :topics, :only => [:index, :show], :has_many => [:posts]
    forum.resources :posts, :member => { :remove => :get }
    forum.resources :post_attachments, :only => [:show]
  end
  
  map.namespace :admin, :member => { :remove => :get }, :path_prefix => 'admin/forum' do |admin|
    admin.resources :forums
    admin.resources :topics
    admin.resources :posts
  end
  
  map.forum_home "/#{forum_prefix}.:format", :controller => 'topics', :action => 'index'
  map.add_comment "/pages/:page_id/posts/new.:format", :controller => 'posts', :action => 'new'
end
