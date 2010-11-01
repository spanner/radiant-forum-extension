class ForumsController < ReaderActionController
  include Radiant::Pagination::Controller
  helper :forum
  
  before_filter :private_forum
  before_filter :find_forum, :only => :show
  before_filter :no_changes_here, :except => [:index, :show]

  radiant_layout { |controller| Radiant::Config['forum.layout'] || Radiant::Config['reader.layout'] }

  def index
    # visible is an open scope that can be overridden in other extensions, ie group_forum
    @forums = Forum.visible.paginate(:all, pagination_parameters.merge(:order => "position"))
  end

  def show
    respond_to do |format|
      format.html { 
        @topics = Topic.paginate_by_forum_id(params[:id], pagination_parameters.merge(:include => :replied_by, :order => 'sticky desc, replied_at desc'))
      }
      format.rss  {
        @topics = Topic.paginate_by_forum_id(params[:id], pagination_parameters.merge(:include => :replied_by, :order => 'replied_at desc'))
        render :layout => 'feed'
      }
    end
  end

  def no_changes_here
    redirect_to admin_forums_url
  end

protected

  def private_forum
    return false unless Radiant::Config['forum.public?'] || require_reader && require_activated_reader
  end

  def find_forum
    @forum = Forum.find(params[:id])
  end

end
