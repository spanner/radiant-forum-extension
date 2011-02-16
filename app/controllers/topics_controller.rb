class TopicsController < ForumBaseController
  
  def index
    @topics = Topic.visible_to(current_reader).bydate.paginate(pagination_parameters)
    render_page_or_feed
  end

  def show
    @topic = Topic.visible_to(current_reader).find(params[:id])
    @forum = @topic.forum
    @posts = @topic.replies.paginate(pagination_parameters)
    render_page_or_feed
  end

end
