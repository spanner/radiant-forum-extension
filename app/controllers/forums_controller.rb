class ForumsController < ForumBaseController
  
  def index
    @forums = Forum.all.paginate(pagination_parameters)
  end

  def show
    @forum = Forum.find(params[:id])
    @topics = @forum.topics.paginate(pagination_parameters)
    render_page_or_feed
  end
  
end
