class ForumPagesDataset < Dataset::Base
  uses :home_page, :users
  
  def load
    create_page "Ordinary", :created_by => users(:admin)
    create_page "Commentable", :commentable => true, :comments_closed => false, :created_by => users(:admin)
    create_page "Uncommentable", :commentable => false, :comments_closed => false, :created_by => users(:admin)
    create_page "Comments closed", :commentable => true, :comments_closed => true, :created_by => users(:admin)
  end
  
end