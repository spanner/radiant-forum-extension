ActionController::Routing::Routes.draw do |map|
  map.with_options :path_prefix => '/forum' do |forum|
    forum.resources :forums, :only => [:index, :show], :has_many => [:topics, :posts]
    forum.resources :topics, :has_many => [:posts]
    forum.resources :posts, :collection => {:search => :get}
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
