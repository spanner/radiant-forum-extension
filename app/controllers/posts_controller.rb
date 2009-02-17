class PostsController < ApplicationController
  no_login_required
  before_filter :find_or_create_topic, :only => [:create]
  before_filter :find_post, :except => [:index, :new, :create, :monitored, :search]
  before_filter :find_forum_and_topic, :except => :index
  before_filter :authenticate_reader, :except => [:index, :show]
  radiant_layout { |controller| controller.find_readers_layout }
  protect_from_forgery :except => :create # because the create form is generated from radius tags, which are defined in a model with no access to the controller

  @@query_options = { :per_page => 25, :select => 'posts.*, topics.title as topic_title, forums.name as forum_name', :joins => 'inner join topics on posts.topic_id = topics.id inner join forums on topics.forum_id = forums.id', :order => 'posts.created_at desc' }
  
  # how do we clear the cache under 0.7?

  # def initialize
  #   super
  #   @cache = ResponseCache.instance
  # end

  def index
    conditions = []
    params.delete :commit
    @searching = false
    [:reader_id, :forum_id, :topic_id, :q].each { |attr| params[attr].blank? ? params.delete(attr) : @searching = true }
    [:reader_id, :forum_id, :topic_id].each { |attr| conditions << Post.send(:sanitize_sql, ["posts.#{attr} = ?", params[attr]]) if params[attr] && !params[attr].blank? }
    conditions << Post.send(:sanitize_sql, ['LOWER(posts.body) LIKE ?', "%#{params[:q]}%"]) unless params[:q].blank?
    conditions = conditions.any? ? conditions.collect { |c| "(#{c})" }.join(' AND ') : nil
    @posts = Post.paginate(:all, @@query_options.merge(:conditions => conditions, :page => params[:page] || 1))
    @user = User.find(params[:user_id]) unless params[:user_id].blank?
    @topic = Topic.find(params[:topic_id]) unless params[:topic_id].blank?
    @forum = Forum.find(params[:forum_id]) unless params[:forum_id].blank?
    @readers = Reader.find(:all, :select => 'distinct *', :conditions => ['id in (?)', @posts.collect(&:user_id).uniq]).index_by(&:id)
    render_page_or_feed
  end

  def monitored
    @searching = true
    options = @@query_options.merge(:conditions => ['monitorships.reader_id = ? and monitorships.active = ?', params[:reader_id], true])
    options[:joins] += ' inner join monitorships on monitorships.topic_id = topics.id'
    options[:page] = params[:page] || 1
    @posts = Post.paginate(:all, options)
    render_page_or_feed
  end

  def show
    respond_to do |format|
      format.html { redirect_to_page_or_topic }
    end
  end

  # new is normally only called by ajax in order to bring the right form into a cached page
  # the view chooses between page-post form and login form
  # page-topic need not exist at this stage.

  def new
    @page = Page.find(params[:page_id])
    respond_to do |format|
      format.html
      format.js { render :layout => false, :template => 'posts/new.html.erb' }
    end
  end

  def create
    if @topic.locked?
      respond_to do |format|
        format.html do
          flash[:notice] = 'This topic is locked.'
          redirect_to_page_or_topic
        end
      end
      return
    end
    @forum = @topic.forum
    @post  = @topic.posts.build(params[:post])
    @post.reader = current_reader
    @post.save!
    # @cache.expire_response(@topic.page.url) if @topic.page
    redirect_to_page_or_topic
    
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'Oi! Post something.'
    redirect :back
  end
  
  def edit
    respond_to do |format| 
      format.html
      format.js
    end
  end
  
  def update
    @post.attributes = params[:post]
    @post.save!
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'An error occurred'
  ensure
    respond_to do |format|
      format.html { redirect_to_page_or_topic }
      format.js {}
      format.json {}
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = "Post deleted."
    # check for posts_count == 1 because it's cached and counting the currently deleted post
    @post.topic.destroy and redirect_to forum_path(params[:forum_id]) if @post.topic && @post.topic.posts_count == 1
    respond_to do |format|
      format.html { redirect_to_page_or_topic }
    end
  end

  protected
    def authorized?
      action_name == 'create' || @post.editable_by?(current_user)
    end
    
    def find_or_create_topic
      if params[:page_id] && !params[:topic_id]
        @page = Page.find(params[:page_id])
        @topic = @page.find_or_create_topic
      else
        @topic = Topic.find(params[:topic_id], :include => :forum)
      end
    end
        
    def find_post
      @post = Post.find_by_id_and_topic_id(params[:id], params[:topic_id]) || raise(ActiveRecord::RecordNotFound)
    end
    
    def render_page_or_feed(template_name = action_name)
      respond_to do |format|
        format.html { render :action => template_name }
        format.rss  { render :action => template_name, :layout => false }
      end
    end
    
    def redirect_to_page_or_topic
      if (@post.topic.page)
        redirect_to @post.topic.page.url + "#comment_#{@post.id}"
      else
        redirect_to topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :page => params[:page] || '1')
      end
      
    end
end
