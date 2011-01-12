class TopicsController < ForumBaseController
  
  def index
    @topics = Topic.all.paginate(pagination_parameters)
    render_page_or_feed
  end

  def show
    @topic = Topic.find(params[:id])
    @posts = @topic.replies.paginate(pagination_parameters)
    render_page_or_feed
  end

end
