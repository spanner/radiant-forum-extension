require "authlogic/test_case"
class ForumReadersDataset < Dataset::Base
  datasets = [:users]
  datasets << :forum_sites if defined? Site
  uses *datasets

  def load
    create_reader "Normal"
    create_reader "Idle"
    create_reader "Activated"
    create_reader "User", :user_id => user_id(:existing)
    create_reader "Admin", :user_id => user_id(:admin)
    create_reader "Inactive", :activated_at => nil
  end
  
  helpers do
    def create_reader(name, attributes={})
      attributes = reader_attributes(attributes.update(:name => name))
      reader = create_model Reader, name.symbolize, attributes
    end
    
    def reader_attributes(attributes={})
      name = attributes[:name] || "John Doe"
      symbol = name.symbolize
      attributes = { 
        :name => name,
        :email => "#{symbol}@spanner.org", 
        :password => "password", 
        :password_confirmation => "password",
        :activated_at => Time.now.utc
      }.merge(attributes)
      attributes[:site_id] ||= site_id(:test) if Reader.reflect_on_association(:site)
      attributes
    end
    
    def reader_params(attributes={})
      password = attributes[:password] || "password"
      reader_attributes(attributes).update(:password => password, :password_confirmation => password)
    end
    
    def login_as_reader(reader)
      activate_authlogic
      login_reader = reader.is_a?(Reader) ? reader : readers(reader)
      ReaderSession.create(login_reader)
      login_reader
    end
    
    def logout_reader
      if session = ReaderSession.find
        session.destroy
      end
    end
  end
 
end