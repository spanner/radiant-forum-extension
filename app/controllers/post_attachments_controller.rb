class PostAttachmentsController < ForumBaseController

  # this simple controller is only here to restrict access to post attachments
  # if the forum is private, and to allow other extensions to add further restrictions
  
  def show
    @attachment = PostAttachment.find(params[:id])
    size = params[:size] || 'original'
    expires_in 1.week, :public => true, :private => false
    send_file @attachment.file.path(size.to_sym), :type => @attachment.file_content_type
  end

end
