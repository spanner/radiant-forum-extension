class TopicsController < ApplicationController
  no_login_required
  
  before_filter :find_forum_and_topic, :except => :index
  before_filter :require_reader, :except => [:index, :show]
  radiant_layout { |controller| controller.layout_for :forum }

  def index
    respond_to do |format|
      format.html do
        @topics = Topic.paginate(:all, :order => "topics.sticky desc, topics.replied_at desc", :page => params[:page] || 1, :include => [:forum, :reader])
      end
      format.rss do
        @topics = Topic.find(:all, :order => "topics.replied_at desc", :include => [:forum, :reader], :limit => 50)
        render :layout => 'feed'
      end
    end
  end

  def new
    @topic = Topic.new
  end
  
  def show
    respond_to do |format|
      format.html do
        @topic.hit! unless current_reader and @topic.reader == current_reader
        @posts = Post.paginate_by_topic_id(@topic.id, :page => params[:page], :include => :reader, :order => 'posts.created_at asc')
      end
      format.rss do
        @posts = @topic.posts.find(:all, :order => 'created_at desc', :limit => 25)
        render :layout => 'feed'
      end
      format.js do
        @posts = Post.paginate_by_topic_id(@topic.id, :page => params[:page], :include => :reader, :order => 'posts.created_at asc')
        render :layout => false
      end
    end
  end
  
  def create
    # post creation is handled by a before_create in the topic model
    # and then calls back to set initial reply data in the topic
    @forum = Forum.find(params[:topic][:forum_id]) if params[:topic][:forum_id]
    @topic = @forum.topics.create!(params[:topic])
    respond_to do |format|
      format.html { redirect_to topic_path(@forum, @topic) }
    end
  rescue ActiveRecord::RecordInvalid => invalid
    flash[:error] = "Sorry: #{invalid}. Please check the form"
    respond_to do |format|
      format.html { render :action => 'new' }
    end
  end
  
  def update
    # post update is handled by a before_update in the topic model
    @topic.attributes = params[:topic]
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
      @page = @topic.page if @topic
    end
    
end
