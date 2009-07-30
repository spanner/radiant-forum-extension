class ForumLayoutsDataset < Dataset::Base
  
  def load
    create_layout "Main"
    create_layout "Reader"
    create_layout "Forum"
  end
  
  helpers do
    def create_layout(name, attributes={})
      create_model :layout, name.symbolize, attributes.update(:name => name)
    end
  end
 
end