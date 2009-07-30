class PostsDataset < Dataset::Base
  uses :topics, :forum_readers
  
  def load
    Page.current_site = sites(:test) if defined? Site

    create_post "First", :topic => topics(:older), :created_at => 2.days.ago, :body => 'first reply: to public topic'
    create_post "Second", :topic => topics(:older), :created_at => 1.day.ago, :body => 'second reply: to public topic'
    create_post "Third", :topic => topics(:private), :created_at => 4.hours.ago, :body => 'third reply: to private topic'
    create_post "Comment", :topic => topics(:comments), :created_at => 1.day.ago, :body => 'first comment on page'

    if defined? Site
      Page.current_site = sites(:elsewhere)
      create_post "Elsewhere", :topic => topics(:elsewhere), :created_at => 1.day.ago, :reader => readers(:elsewhere), :body => 'first reply to topic elsewhere'
    end
  end
  
  helpers do
    def create_post(name, attributes={})
        attributes = post_attributes(attributes.update(:name => name))
        create_model :post, name.symbolize, attributes
      end
    end

    def post_attributes(attributes={})
      name = attributes[:name] || "A topic"
      att = {
        :name => name,
        :reader => readers(:normal),
        :created_at => Time.now
      }.merge(attributes)
      att
    end
 
end