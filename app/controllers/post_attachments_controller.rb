class PostAttachmentsController < ForumBaseController

  # this simple controller exists for two reasons: to use sendfile for attachments (but it doesn't, yet)
  # and to allow other extensions (ie group_forum) to restrict access to post attachments
  
  def show
    @attachment = PostAttachment.find(params[:id])
    size = params[:size] || 'original'
    expires_in SiteController.cache_timeout, :public => true, :private => false
    send_file @attachment.file.path(size.to_sym), :type => @attachment.file_content_type, :disposition => 'inline'
  end

end
