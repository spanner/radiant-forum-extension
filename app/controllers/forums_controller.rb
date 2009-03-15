class ForumsController < ApplicationController
  no_login_required
  radiant_layout { |controller| controller.layout_for :forum }

  def index
    @forums = Forum.paginate(:all, :order => "position", :page => params[:page] || 1)
  end

  def show
    @forum = Forum.find(params[:id]) 
    respond_to do |format|
      format.html { 
        @topics = Topic.paginate_by_forum_id(params[:id], :page => params[:page] || 1, :include => :replied_by, :order => 'sticky desc, replied_at desc')
      }
      format.rss  {
        @topics = Topic.paginate_by_forum_id(params[:id], :page => params[:page] || 1, :include => :replied_by, :order => 'replied_at desc')
        render :layout => false 
      }
    end
  end

  def no_changes_here
    redirect_to admin_forums_url
  end
  
  alias_method :new, :no_changes_here
  alias_method :create, :no_changes_here
  alias_method :edit, :no_changes_here
  alias_method :update, :no_changes_here
  alias_method :remove, :no_changes_here
  alias_method :destroy, :no_changes_here

end
