class ForumsDataset < Dataset::Base
  uses :forum_sites
  
  def load
    create_forum "Public", :site => sites(:test)
    create_forum "Private", :site => sites(:test)
    create_forum "Misc", :site => sites(:test)
    create_forum "Comments", :site => sites(:test), :for_comments => true
    create_forum "Elsewhere", :site => sites(:elsewhere)
  end
  
  helpers do
    def create_forum(name, attributes={})
      create_model :forum, name.symbolize, attributes.update(:name => name)
    end
  end
 
end