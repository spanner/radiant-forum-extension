class ForumsDataset < Dataset::Base
  
  def load
    create_forum "Public"
    create_forum "Private"
    create_forum "Misc"
  end
  
  helpers do
    def create_forum(name, attributes={})
      create_record :forum, name.symbolize, attributes.update(:name => name)
    end
  end
 
end