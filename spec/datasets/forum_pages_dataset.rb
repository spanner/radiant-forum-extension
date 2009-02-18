class ForumPagesDataset < Dataset::Base
  uses :home_page
  
  def load
    create_page "Not Commentable", :commentable => false, :comments_closed => false
    create_page "Commentable", :commentable => true, :comments_closed => false
    create_page "Comments closed", :commentable => true, :comments_closed => true
  end
  
end