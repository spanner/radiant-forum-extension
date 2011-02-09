ActionController::Routing::Routes.draw do |map|
  map.with_options :path_prefix => '/forum' do |forum|
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
  
  map.forum_home "/forum.:format", :controller => 'topics', :action => 'index'
  map.add_comment "/pages/:page_id/posts/new.:format", :controller => 'posts', :action => 'new'

end
