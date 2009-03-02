module ForumReadersController

  def self.included(base)
    base.class_eval do
      alias_method_chain :show, :forum 
    end
  end

  def show_with_forum
    @reader = Reader.find(params[:id])
    @posts = Post.paginate_by_reader_id(@reader.id, :page => params[:page], :include => :topic, :order => 'posts.created_at desc') if @reader
    render :template => 'readers/show_with_posts'
  end

end
