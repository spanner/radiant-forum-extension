class ForumsController < ReaderActionController
  skip_before_filter :require_reader
  before_filter :no_changes_here, :except => [:index, :show]
  radiant_layout { |controller| controller.layout_for :forum }

  def index
    @forums = Forum.paginate(:all, :order => "position", :page => params[:page] || 1, :per_page => params[:per_page] || 20)
  end

  def show
    @forum = Forum.find(params[:id]) 
    respond_to do |format|
      format.html { 
        @topics = Topic.paginate_by_forum_id(params[:id], :page => params[:page] || 1, :per_page => params[:per_page] || 20, :include => :replied_by, :order => 'sticky desc, replied_at desc')
      }
      format.rss  {
        @topics = Topic.paginate_by_forum_id(params[:id], :page => params[:page] || 1, :per_page => params[:per_page] || 20, :include => :replied_by, :order => 'replied_at desc')
        render :layout => 'feed'
      }
    end
  end

  def no_changes_here
    redirect_to admin_forums_url
  end

end
