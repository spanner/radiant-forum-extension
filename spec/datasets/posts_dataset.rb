class PostsDataset < Dataset::Base
  uses :topics, :forum_readers
  
  def load
    Page.current_site = sites(:test)
    create_post "First", :topic => topics(:older), :reader => readers(:normal), :body => 'first reply: to public topic'
    create_post "Second", :topic => topics(:older), :reader => readers(:normal), :body => 'second reply: to public topic'
    create_post "Third", :topic => topics(:private), :reader => readers(:normal), :body => 'third reply: to private topic'
    create_post "Comment", :topic => topics(:comments), :reader => readers(:normal), :body => 'first comment on page'

    Page.current_site = sites(:elsewhere)
    create_post "Elsewhere", :topic => topics(:elsewhere), :reader => readers(:elsewhere), :body => 'first reply to topic elsewhere'
  end
  
  helpers do
    def create_post(name, attributes={})
      create_model Post, name.symbolize, attributes
    end
  end
 
end