class TopicsController < ApplicationController
  no_login_required
  before_filter :find_forum_and_topic, :except => :index
  before_filter :authenticate_reader, :except => [:index, :show]
  radiant_layout { |controller| controller.find_readers_layout }

  def index
    redirect_to forum_path(params[:forum_id])
  end

  def new
    @topic = Topic.new
  end
  
  def show
    respond_to do |format|
      format.html do
        # authors of topics don't get counted towards total hits
        @topic.hit! unless current_reader and @topic.reader == current_reader
        @posts = Post.paginate_by_topic_id(@topic.id, :page => params[:page], :include => :user, :order => 'posts.created_at asc')
      end
      format.rss do
        @posts = @topic.posts.find(:all, :order => 'created_at desc', :limit => 25)
        render :layout => false
      end
    end
  end
  
  def create
    # this is icky - move the topic/first post workings into the topic model?
    Topic.transaction do
      @topic  = @forum.topics.build(params[:topic])
      assign_protected
      @post   = @topic.posts.build(params[:topic])
      @post.topic = @topic
      @post.user = current_user
      # only save topic if post is valid so in the view topic will be a new record if there was an error
      @topic.body = @post.body # in case save fails and we go back to the form
      @topic.save! if @post.valid?
      @post.save! 
    end
    respond_to do |format|
      format.html { redirect_to topic_path(@forum, @topic) }
    end
  end
  
  def update
    @topic.attributes = params[:topic]
    assign_protected
    @topic.save!
    respond_to do |format|
      format.html { redirect_to topic_path(@forum, @topic) }
    end
  end
  
  def destroy
    @topic.destroy
    flash[:notice] = "Topic '{title}' was deleted."[:topic_deleted_message, CGI::escapeHTML(@topic.title)]
    respond_to do |format|
      format.html { redirect_to forum_path(@forum) }
    end
  end
  
  protected
    def assign_protected
      @topic.reader = current_reader if @topic.new_record?
    end
    
    def find_forum_and_topic
      @forum = Forum.find(params[:forum_id]) if params[:forum_id]
      @topic = @forum.topics.find(params[:id]) if params[:id]
    end
    
end
