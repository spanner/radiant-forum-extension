class ForumsDataset < Dataset::Base
  uses :forum_sites if defined? Site
  
  def load
    create_forum "Public"
    create_forum "Private"
    create_forum "Misc"
    create_forum "Comments", :for_comments => true
    create_forum "Elsewhere", :site => sites(:elsewhere) if defined? Site
  end
  
  helpers do
    def create_forum(name, attributes={})
      attributes[:site] ||= sites(:test) if defined? Site
      create_model :forum, name.symbolize, attributes.update(:name => name)
    end
  end
 
end