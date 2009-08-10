class ForumsDataset < Dataset::Base
  uses :forum_sites if defined? Site
  
  def load
    create_forum "Public"
    create_forum "Private"
    create_forum "Misc"
    create_forum "Comments", :for_comments => true
  end
  
  helpers do
    def create_forum(name, attributes={})
      create_model :forum, name.symbolize, attributes.update(:name => name)
    end
    
    def forum_attributes(attributes={})
      name = attributes[:name] || "Forum"
      symbol = name.symbolize
      attributes = { 
        :name => name,
      }.merge(attributes)
      attributes[:site] = sites(:test) if defined? Site
      attributes
    end
    
  end
 
end