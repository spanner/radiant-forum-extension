class ForumReadersDataset < Dataset::Base
  
  def load
    create_reader "Normal"
    create_reader "Idle"
    create_reader "Industrious"
    create_reader "Inactive"
  end
  
  helpers do
    def create_reader(name, attributes={})
      create_record :reader, name.symbolize, reader_attributes(attributes.update(:name => name))
    end
    
    def reader_attributes(attributes={})
      name = attributes[:name] || "John Doe"
      symbol = name.symbolize
      attributes = { 
        :name => name,
        :email => "#{symbol}@spanner.org", 
        :login => symbol.to_s,
        :password => "password"
      }.merge(attributes)
      attributes
    end
  end
end