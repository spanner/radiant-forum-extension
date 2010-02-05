class PostsController < ReaderActionController

  before_filter :set_site_title
  before_filter :require_activated_reader, :except => [:index, :show, :search]
  before_filter :find_topic_or_page, :except => [:index, :search]
  before_filter :require_unlocked_topic_and_page, :only => [:new, :create]
  before_filter :find_post, :only => [:show, :edit, :update]
  before_filter :build_post, :only => [:new]
  before_filter :require_authority, :only => [:edit, :update, :destroy]

  radiant_layout { |controller| controller.layout_for(:forum) }

  @@default_query_options = { 
    :page => 1,
    :per_page => 20,
    :order => 'posts.created_at desc',
    :include => [:topic, :forum, :reader]
  }
  
  def index
    @posts = Post.visible.paginate(:all, @@default_query_options.merge(:page => params[:page], :per_page => params[:per_page]))
    render_page_or_feed
  end

  def search
    conditions = []
    @reader = Reader.find(params[:reader_id]) unless params[:reader_id].blank?
    @topic = Topic.find(params[:topic_id]) unless params[:topic_id].blank?
    @forum = Forum.find(params[:forum_id]) unless params[:forum_id].blank?

    conditions << Post.send(:sanitize_sql, ["posts.reader_id = ?", @reader.id]) if @reader
    conditions << Post.send(:sanitize_sql, ["posts.topic_id = ?", @topic.id]) if @topic
    conditions << Post.send(:sanitize_sql, ["posts.forum_id = ?", @forum.id]) if @forum
    conditions << Post.send(:sanitize_sql, ['LOWER(posts.body) LIKE ?', "%#{params[:q]}%"]) unless params[:q].blank?
    @searching = true if conditions.any?
    
    @posts = Post.paginate(:all, @@default_query_options.merge(:conditions => @searching ? conditions.collect { |c| "(#{c})" }.join(' AND ') : nil, :page => params[:page], :per_page => params[:per_page]))

    # for summary of the set, and onward links
    @forums = @posts.collect(&:forum).uniq
    @topics = @posts.collect(&:topic).uniq
    @readers = @posts.collect(&:reader).uniq
    
    if @searching
      @title = "Search Results"
      @description = "Posts"
      @description << " matching '#{params[:q]}'" unless params[:q].blank?
      @description << " from #{@reader.name}" if @reader
      if @topic
        @description << " under #{@topic.name}"
      elsif @forum
        @description << " in #{@forum.name}"
      end
    end
    
    render_page_or_feed
  end

  def monitored
    @searching = true
    options = @@query_options.merge(:conditions => ['monitorships.reader_id = ? and monitorships.active = ?', params[:reader_id], true])
    options[:joins] += ' inner join monitorships on monitorships.topic_id = topics.id'
    options[:page] = params[:page] || 1
    @posts = Post.paginate(:all, options)
    @title = "Topics you're watching"
    render_page_or_feed
  end

  def show
    respond_to do |format|
      format.html { redirect_to_page_or_topic }
      format.js { render :layout => false }
    end
  end

  # this is typically called by xht to bring a comment form into a page or a reply form into a topic
  # if the reader is not logged in, reader_required should have intervened and caused the return of a login form instead

  def new
    respond_to do |format|
      format.html { render :template => 'posts/new' } # we specify the template because in theory we could be reverting from a post to create 
      format.js { render :partial => 'posts/reply' }
    end
  end
    
  def create
    if @topic.new_record?
      # only happens if it's a page comment and the topic has just been built
      # in that case we can let the topic-creation routines do the post work
      @topic.body = params[:post][:body]
      @topic.reader = current_reader
      @topic.save!
      @post = @topic.first_post
    else
      @post = @topic.posts.create!(params[:post])
    end

    @post.save_attachments(params[:files]) unless @page && !Radiant::Config['forum.comments_have_attachments']
    Radiant::Cache.clear if @page

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
    @post.save_attachments(params[:files])
    Radiant::Cache.clear if @post.topic.page
  rescue ActiveRecord::RecordInvalid
    flash[:error] = "Sorry: message can't be empty"
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
    (current_user && current_user.admin?) || @post.editable_by?(current_reader)      # includes an editable-interval check
  end
          
  def find_topic_or_page
    if params[:page_id]
      @page = Page.find(params[:page_id])
      @topic = @page.find_or_build_topic
      @forum = @topic.forum if @topic
    elsif params[:topic_id]
      @topic = Topic.find(params[:topic_id], :include => :forum)
      @forum = @topic.forum if @topic
    end
  end
  
  def require_unlocked_topic_and_page
    return page_locked if @page && @page.locked?
    return topic_locked if @topic.locked?
    true
  end

  def find_post
    @post = @topic.posts.find(params[:id])
  end
  
  def build_post
    @post = Post.new(params[:post])
    @post.topic = @topic if @topic
    @post.reader = current_reader
  end
  
  def redirect_to_page_or_topic   
    if (@topic.page)
      post_location = @post ? "##{@post.dom_id}" : ""
      redirect_to @topic.page.url + post_location
    else
      post_location = @post ? {:page => @post.topic_page, :anchor => @post.dom_id} : {}
      redirect_to forum_topic_url(@topic.forum, @topic, post_location)
    end
  end

  def redirect_to_forum
    redirect_to forum_url(@topic.forum)
  end
  
  def page_locked
    respond_to do |format|
      format.html {
        flash[:error] = 'This page is not commentable.'
        redirect_to @page.url
      }
      format.js {
        render :template => 'locked', :layout => false
      }
    end
    false
  end
  
  def topic_locked
    respond_to do |format|
      format.html {
        flash[:error] = 'This topic is locked.'
        redirect_to_page_or_topic
      }
      format.js {
        render :partial => 'topics/locked'
      }
    end
    false
  end

end
