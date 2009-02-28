class PostsController < ApplicationController
  no_login_required
  before_filter :find_topic, :except => [:create, :index]
  before_filter :find_or_create_page_topic, :only => [:create]
  before_filter :find_page, :only => [:new, :create]
  before_filter :find_post, :except => [:index, :new, :create, :monitored]
  before_filter :authenticate_reader, :except => [:index, :show]
  radiant_layout { |controller| controller.find_readers_layout }
  protect_from_forgery :except => :create # because the create form is typically generated from radius tags, which are defined in a model with no access to the controller

  @@query_options = { :per_page => 25, :select => 'posts.*, topics.name as topic_name, forums.name as forum_name', :joins => 'inner join topics on posts.topic_id = topics.id inner join forums on topics.forum_id = forums.id', :order => 'posts.created_at desc' }
  
  # *** clear the cache

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
    @reader = Reader.find(params[:reader_id]) unless params[:reader_id].blank?
    @topic = Topic.find(params[:topic_id]) unless params[:topic_id].blank?
    @forum = Forum.find(params[:forum_id]) unless params[:forum_id].blank?
    @readers = Reader.find(:all, :select => 'distinct *', :conditions => ['id in (?)', @posts.collect(&:reader_id).uniq]).index_by(&:id)

    @title = current_site.name
    @title << ": posts"
    @title << " matching '#{params[:q]}'" if params[:q]
    @title << " from #{@reader.name}" if @reader
    if @topic
      @title << " under #{@topic.name}"
    elsif @forum
      @title << " in #{@forum.name}"
    end
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

  # this is typically called by ajax to bring a comment form into a page or a reply form into a topic
  # if the reader is not logged in, authenticate_reader should intervene and return a login form instead

  def new
    return topic_locked if @topic.locked?
    respond_to do |format|
      format.html
      format.js { 
        render :template => 'posts/new.html.erb', :layout => false
      }
    end
  end
  
  def create
    return topic_locked if @topic.locked?
    @forum = @topic.forum
    @post  = @topic.posts.build(params[:post])
    @post.reader = current_reader
    @post.save!
    # @cache.expire_response(@topic.page.url) if @topic.page          # *** clear the cache
    respond_to do |format|
      format.html { 
        redirect_to_page_or_topic
      }
      format.js {
        render :action => 'show', :layout => false
      }
    end
    
  rescue ActiveRecord::RecordInvalid => oops
    flash[:error] = oops
    respond_to do |format|
      format.html { 
        render :action => 'new' 
      }
      format.js {
        render :action => 'new', :layout => false
      }
    end

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
            
    def find_topic
      @topic = Topic.find_by_id(params[:topic_id], :include => :forum) || raise(ActiveRecord::RecordNotFound)
    end

    def find_or_create_page_topic
      if params[:page_id] && !params[:topic_id]
        @page = Page.find(params[:page_id])
        @topic = @page.find_or_create_topic
      else
        @topic = Topic.find(params[:topic_id], :include => :forum)
      end
    end

    def find_page
      @page = Page.find(params[:page_id]) if params[:page_id]
    end

    def find_post
      @post = @topic.posts.find(params[:id]) || raise(ActiveRecord::RecordNotFound)
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
        redirect_to topic_url(@topic.forum, @topic, {:page => @post.topic_page, :anchor => "post_#{@post.id}"})
      end
    end
    
    def topic_locked
      respond_to do |format|
        format.html {
          flash[:notice] = 'This topic is locked.'
          redirect_to topic_url(@topic.forum, @topic)
        }
        format.js {
          render :template => 'locked', :layout => false
        }
      end
    end
    
end
