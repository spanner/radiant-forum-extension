class Admin::PostsController < Admin::ResourceController
  helper :forum
  paginate_models
  
  only_allow_access_to :new, :create, :edit, :update, :remove, :destroy,
    :when => :admin,
    :denied_url => { :controller => 'pages', :action => 'index' },
    :denied_message => 'You must be an administrator to edit posts.'
  
end
