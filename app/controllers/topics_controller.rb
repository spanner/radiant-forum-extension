class TopicsController < ApplicationController
  no_login_required
  before_filter :find_forum_and_topic
  before_filter :authenticate_reader, :except => [:index, :show]
  radiant_layout { |controller| controller.find_readers_layout }

  def index
    if @forum
      @topics = @forum.topics.paginate(:all, :order => "topics.sticky desc, topics.replied_at desc", :page => params[:page] || 1, :include => [:reader])
    else
      @topics = Topic.paginate(:all, :order => "topics.sticky desc, topics.replied_at desc", :page => params[:page] || 1, :include => [:forum, :reader])
    end
  end

  def new
    @topic = Topic.new
  end
  
  def show
    respond_to do |format|
      format.html do
        # authors of topics don't get counted towards total hits
        @topic.hit! unless current_reader and @topic.reader == current_reader
        @posts = Post.paginate_by_topic_id(@topic.id, :page => params[:page], :include => :reader, :order => 'posts.created_at asc')
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
      @topic = @forum.topics.build(params[:topic])
      @post = @topic.posts.build(params[:topic])
      @post.topic = @topic    # wtf this doesn't just happen i have no idea.
      @topic.save! if @post.valid? # so if post is invalid, topic will still be a new record
      @post.save!
    end
    respond_to do |format|
      format.html { redirect_to topic_path(@forum, @topic) }
    end
  rescue ActiveRecord::RecordInvalid => invalid
    flash[:error] = "Sorry: something is missing. Please check the form"
    respond_to do |format|
      format.html { render :action => 'new' }
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
    flash[:notice] = "Topic '{name}' was deleted."[:topic_deleted_message, CGI::escapeHTML(@topic.name)]
    respond_to do |format|
      format.html { redirect_to forum_path(@forum) }
    end
  end
  
  protected

    def find_forum_and_topic
      @forum = Forum.find(params[:forum_id]) if params[:forum_id]
      @topic = @forum.topics.find(params[:id]) if params[:id]
    end
    
end
