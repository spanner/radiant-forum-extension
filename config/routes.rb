ActionController::Routing::Routes.draw do |map|
  map.with_options :path_prefix => '/forum' do |forum|
    forum.resources :forums, :only => [:index, :show], :has_many => [:topics, :posts]
    forum.resources :topics, :has_many => [:posts]
    forum.resources :posts, :collection => {:search => :get}
    forum.resources :pages, :has_many => [:posts], :has_one => [:topic]
  end
  
  map.namespace :admin, :member => { :remove => :get }, :path_prefix => 'admin/forum' do |admin|
    admin.resources :forums
    admin.resources :topics
    admin.resources :posts
  end
  
  map.forum_home "/forum.:format", :controller => 'topics', :action => 'index'
end
