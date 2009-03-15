class ForumLayoutsDataset < Dataset::Base
  uses :forum_sites if defined? Site
  
  def load
    create_layout "Main"
    create_layout "Reader"
    create_layout "Forum"
  end
  
  helpers do
    def create_layout(name, attributes={})
      attributes[:site] ||= sites(:test) if defined? Site
      create_model :layout, name.symbolize, attributes.update(:name => name)
    end
  end
 
end