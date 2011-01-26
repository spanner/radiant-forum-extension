class ForumBaseController < ReaderActionController

  include Radiant::Pagination::Controller
  radiant_layout { |c| Radiant::Config['forum.layout'] || Radiant::Config['reader.layout'] }
  before_filter :require_login_unless_public
  before_filter :establish_context
  helper :forum, :reader

protected

  def require_login_unless_public
    return false unless Radiant::Config['forum.public?'] || require_reader && require_activated_reader
  end
  
  def establish_context
    @reader = Reader.find(params[:reader_id]) unless params[:reader_id].blank?
    @topic = Topic.find(params[:topic_id]) unless params[:topic_id].blank?
    @forum = Forum.find(params[:forum_id]) unless params[:forum_id].blank?
    @page = Page.find(params[:page_id]) unless params[:page_id].blank?
  end

  def redirect_to_post
    
    Rails.logger.warn "!!! redirecting to post #{@post.inspect}"
    Rails.logger.warn "!   which will have topic #{@post.topic} and within it page #{@post.page_when_paginated}"
    
    if (@post.page)
      redirect_to "#{@post.page.url}?#{WillPaginate::ViewHelpers.pagination_options[:param_name]}=#{@post.page_when_paginated}##{@post.dom_id}"
    elsif @post.first?
      redirect_to forum_topic_path(@post.topic.forum, @post.topic)
    else
      post_location = {WillPaginate::ViewHelpers.pagination_options[:param_name] => @post.page_when_paginated, :anchor => @post.dom_id}
      redirect_to forum_topic_url(@post.topic.forum, @post.topic, post_location)
    end
  end

  def redirect_to_topic
    redirect_to forum_topic_path(@forum, @topic)
  end
  
  def redirect_to_page_or_topic
    if @page
      redirect_to @page.url
    elsif @topic
      redirect_to forum_topic_url(@topic.forum, @topic)
    end
  end

  def redirect_to_forum
    respond_to do |format|
      format.html { redirect_to forum_path(@forum) }
    end
  end

  def render_page_or_feed(template_name = action_name)
    respond_to do |format|
      format.html { render :action => template_name }
      format.rss { render :action => template_name, :layout => 'feed' }
      format.js { render :action => template_name, :layout => false }
    end
  end
  
  def redirect_to_admin
    redirect_to admin_forums_url
  end

  def render_locked
    respond_to do |format|
      format.html { 
        flash[:error] = t('topic_locked')
        redirect_to_page_or_topic 
      }
      format.js { render :partial => 'topics/locked' }
    end
    false
  end

end
