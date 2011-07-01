class PostsController < ForumBaseController
  
  before_filter :require_activated_reader, :except => [:index, :show]
  before_filter :find_post, :only => [:show, :edit, :update, :remove, :destroy]
  before_filter :require_unlocked_topic_and_page, :only => [:new, :create]
  before_filter :build_post, :only => [:new, :create]
  before_filter :require_authority, :only => [:edit, :update, :destroy]

  def index
    @term = params[:q]
    posts = Post.visible_to(current_reader)
    posts = posts.matching(@term) unless @term.blank?
    posts = posts.from_reader(@reader) if @reader
    posts = posts.in_forum(@forum) if @forum
    posts = posts.in_topic(@topic) if @topic
    @posts = posts.paginate(pagination_parameters)
    respond_to do |format|
      format.html
      format.js { render :partial => 'search_results' }
      format.rss { render :layout => 'feed' }
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to_post }
      format.js { render :layout => false }
    end
  end

  def new
    unless @post.topic || @post.page
      if @forum ||= Forum.find_by_name(Radiant::Config['forum.default_forum'])
        @post.topic = @forum.topics.new
      else
        @post.topic = Topic.new
      end
    end
    respond_to do |format|
      format.html {
        @inline = false
        render
      }
      format.js {
        @inline = true
        if @post.page
          # page comment form is usually brought in by xhr so that page itself can be cached
          render :partial => 'pages/add_comment', :layout => false
        else
          # this is a much less common case, but you can cache topic pages if you really want to
          render :partial => 'topics/reply', :layout => false
        end
      }
    end
  end
  
  def create
    @post.save!
    Radiant::Cache.clear if @post.page
    respond_to do |format|
      format.html { redirect_to_post }
      format.js { render :partial => 'post' }
    end
  rescue ActiveRecord::RecordInvalid
    flash[:error] = t("forum_extension.validation_failure")
    respond_to do |format|
      format.html { render :action => 'new' }
      format.js { render :partial => 'form' }
    end
  end

  def edit
    respond_to do |format| 
      format.html {
        @inline = false
        render
      }
      format.js { 
        @inline = true
        if current_reader.is_moderator?(@post) || @post.editable_by?(current_reader)
          render :partial => 'form' 
        else
          render :partial => 'ineditable' 
        end
      }
    end
  end
  
  def update
    @post.attributes = params[:post]
    @post.save!
    Radiant::Cache.clear if @post.page || (@post.topic && Radiant.config['forum.cached?'])
    respond_to do |format|
      format.html { redirect_to_post }
      format.js { render :partial => 'post' }
    end
  rescue ActiveRecord::RecordInvalid
    flash[:error] = t("forum_extension.validation_failure")
    respond_to do |format|
      format.html { render :action => 'edit' }
      format.js { render :partial => 'form' }
    end
  end

  def remove
    respond_to do |format|
      format.html { expires_now }
      format.js { render :partial => 'confirm_delete' }
    end
  end

  def destroy
    if @post.first?
      @post.topic.destroy
      flash[:notice] = t("forum_extension.topic_removed")
      redirect_to_forum
    else
      @post.destroy
      respond_to do |format|
        format.html { 
          flash[:notice] = t("forum_extension.post_removed")
          redirect_to_page_or_topic 
        }
        format.js { render :partial => 'post' }
      end
    end
  end

protected

  def find_post
    @post ||= Post.visible_to(current_reader).find(params[:id])
  end

  def require_authority
    current_reader.is_admin? || @post.editable_by?(current_reader)      # includes an editable-interval check
  end
          
  def require_unlocked_topic_and_page
    return render_locked if @page && @page.locked?
    return render_locked if @topic && @topic.locked?
    true
  end

  def build_post
    @post = Post.new(params[:post])
    @post.reader = current_reader
    @post.page ||= @page
    @post.topic ||= @topic
  end
    
end
