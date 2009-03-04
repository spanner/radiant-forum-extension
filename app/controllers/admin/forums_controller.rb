class Admin::ForumsController < Admin::ResourceController

  # # I have no idea where this default is being overridden
  # skip_before_filter :verify_authenticity_token if ENV["RAILS_ENV"] == "test"

  only_allow_access_to :new, :create, :edit, :update, :remove, :destroy,
    :when => :admin,
    :denied_url => { :controller => 'pages', :action => 'index' },
    :denied_message => 'You must be an administrator to add or change discussion categories.'
  
end
