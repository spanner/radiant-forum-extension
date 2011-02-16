class ForumsController < ForumBaseController
  
  def index
    @forums = Forum.visible_to(current_reader).paginate(pagination_parameters)
    render_page_or_feed
  end

  def show
    @forum = Forum.visible_to(current_reader).find(params[:id])
    @topics = @forum.topics.stickyfirst.paginate(pagination_parameters)
    render_page_or_feed
  end
  
end
