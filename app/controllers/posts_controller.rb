class PostsController < ApplicationController
  require 'cgi'

  no_login_required
  before_filter :authenticate_reader, :except => [:index, :show]
  before_filter :require_authority, :only => [:edit, :update, :destroy]
  before_filter :find_topic_or_page, :except => [:index]
  before_filter :find_post, :except => [:index, :new, :preview, :create, :monitored]
  before_filter :build_post, :only => [:new]
  radiant_layout { |controller| controller.layout_for :forum }

  # protect_from_forgery :except => :create # because the post form is typically generated from radius tags, which are defined in a model with no access to the controller

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

    @title = ((defined? Site) ? current_site.name : Radiant::Config['site.title']) || ''
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
      format.js { render :layout => false }
    end
  end

  # this is typically called by ajax to bring a comment form into a page or a reply form into a topic
  # if the reader is not logged in, authenticate_reader should intervene and return a login form instead

  def new
    return topic_locked if @topic && @topic.locked?
    respond_to do |format|
      format.html { render :template => 'posts/new' } # we specify because sometimes we're reverting from a post to create 
      format.js { render :template => 'posts/new', :layout => false }
    end
  end
    
  def create
    return topic_locked if @topic.locked?
    if @topic.new_record?
      # only happens if it's a page comment and the topic has just been built
      # in that case we let the topic-creation routines do the post work
      @topic.body = params[:post][:body]
      @topic.save!
      @post = @topic.first_post
    else
      @post = @topic.posts.create!(params[:post])
    end
    
    params[:files].each do |file|
      attachment = @post.attachments.create( :reader => current_reader, :file => file )
    end
    
    cache.expire_response(@page.url) if @page
    respond_to do |format|
      format.html { redirect_to_page_or_topic }
      format.js { render :action => 'show', :layout => false }
    end
  rescue ActiveRecord::RecordInvalid
    flash[:error] = 'Problem!'
    respond_to do |format|
      format.html { render :action => 'new' }
      format.js { render :action => 'new', :layout => false }
    end
  end

  def topic_locked
    respond_to do |format|
      format.html do
        flash[:notice] = 'Topic is locked.'
        redirect_to_page_or_topic
      end
      format.js { render :partial => 'topics/locked' }
    end
    return
  end
    
  def edit
    respond_to do |format| 
      format.html { render }
      format.js { render :layout => false }
    end
  end
  
  def update
    @post.attributes = params[:post]
    @post.save!
    params[:files].each do |file|
      attachment = @post.attachments.create( :reader => current_reader, :file => file )
    end
    cache.expire_response(@post.topic.page.url) if @post.topic.page
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'Zut Alors!'
  ensure
    respond_to do |format|
      format.html { redirect_to_page_or_topic }
      format.js { render :partial => 'post', :layout => false }
      format.json { render :json => @post.as_json }
    end
  end

  def destroy
    if @post.first?
      @post.topic.destroy
      flash[:notice] = "Topic removed"
      respond_to do |format|
        format.html { redirect_to_forum }
        format.js { render :partial => 'post', :layout => false }
      end
    else
      @post.destroy
      flash[:notice] = "Post removed"
      respond_to do |format|
        format.html { redirect_to_page_or_topic }
        format.js { render :partial => 'post', :layout => false }
      end
    end
  end

  protected
    def require_authority
      current_user.admin? || @post.editable_by?(current_reader)      # includes an editable-interval check
    end
            
    def find_topic_or_page
      if params[:page_id]
        @page = Page.find(params[:page_id])
        @topic = @page.find_or_build_topic
        @forum = @topic.forum
      elsif params[:topic_id]
        @topic = Topic.find(params[:topic_id], :include => :forum)
        @forum = @topic.forum
      end
    end

    def find_post
      @post = @topic.posts.find(params[:id])
    end
    
    def build_post
      @post = Post.new(params[:post])
      @post.topic = @topic if @topic
      @post.reader = current_reader
    end

    def render_page_or_feed(template_name = action_name)
      respond_to do |format|
        format.html { render :action => template_name }
        format.rss  { render :action => template_name, :layout => false }
        format.js  { render :action => template_name, :layout => false }
      end
    end
    
    def redirect_to_page_or_topic
      if (@post.topic.page)
        redirect_to @post.topic.page.url + "#comment_#{@post.id}"
      else
        redirect_to topic_url(@topic.forum, @topic, {:page => @post.topic_page, :anchor => "post_#{@post.id}"})
      end
    end

    def redirect_to_forum
      redirect_to forum_url(@topic.forum)
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
