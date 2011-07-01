class ForumBaseController < ReaderActionController

  include Radiant::Pagination::Controller
  radiant_layout { |c| Radiant::Config['forum.layout'] || Radiant::Config['reader.layout'] }
  before_filter :require_login_unless_public
  before_filter :establish_context
  before_filter :require_visibility_to_reader
  helper :forum, :reader

protected

  def set_cache_header
    if Radiant.config['forum.cached?']
      expires_in (Radiant.config['forum.cache_duration'] || 60).to_i.minutes, :public => true
    else
      expires_now
    end
  end
  
  def require_login_unless_public
    return false unless Radiant::Config['forum.public?'] || require_reader && require_activated_reader
  end
  
  def require_visibility_to_reader
    if @page && !@page.visible_to?(current_reader)
      flash[:error] = t("page_not_public")
      redirect_to reader_permission_denied_url
      return false
    end
    
    if @forum && !@forum.visible_to?(current_reader)
      flash[:error] = "forum_not_public"
      redirect_to reader_permission_denied_url
      return false
    end
  end
  
  def establish_context
    @reader = Reader.find(params[:reader_id]) unless params[:reader_id].blank?
    @topic = Topic.visible_to(current_reader).find(params[:topic_id]) unless params[:topic_id].blank?
    @forum = Forum.visible_to(current_reader).find(params[:forum_id]) unless params[:forum_id].blank?
    @page = Page.visible_to(current_reader).find(params[:page_id]) unless params[:page_id].blank?
  end
  
  def redirect_to_post
    if (@post.page)
      redirect_to "#{@post.page.url}?#{WillPaginate::ViewHelpers.pagination_options[:param_name]}=#{@post.page_when_paginated}##{@post.dom_id}"
    elsif @post.first?
      redirect_to topic_path(@post.topic)
    else
      post_location = {WillPaginate::ViewHelpers.pagination_options[:param_name] => @post.page_when_paginated, :anchor => @post.dom_id}
      redirect_to topic_path(@post.topic, post_location)
    end
  end

  def redirect_to_topic
    redirect_to topic_path(@topic)
  end
  
  def redirect_to_page_or_topic
    if @page
      redirect_to @page.url
    elsif @topic
      redirect_to topic_path(@topic)
    end
  end

  def redirect_to_forum
    respond_to do |format|
      format.html { redirect_to forum_path(@forum) }
    end
  end

  def render_page_or_feed(template_name = action_name)
    respond_to do |format|
      format.html { 
        set_cache_header
        render :action => template_name 
      }
      format.rss { 
        render :action => template_name, :layout => 'feed'
      }
      format.js { 
        render :action => template_name, :layout => false
      }
    end
  end
  
  def redirect_to_admin
    redirect_to admin_forums_url
  end

  def render_locked
    respond_to do |format|
      format.html { 
        expires_now
        flash[:error] = t('forum_extension.topic_locked')
        redirect_to_page_or_topic 
      }
      format.js { render :partial => 'topics/locked' }
    end
    false
  end

end
