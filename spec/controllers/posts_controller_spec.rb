require File.dirname(__FILE__) + '/../spec_helper'
Radiant::Config['reader.layout'] = 'Main'

describe PostsController do
  dataset :layouts
  dataset :forum_readers
  
  before do
    @forum = Forum.create(:name => "test forum")
    @topic = @forum.topics.build(:name => "test topic")
    @topic.reader = readers(:normal)
    @topic.save!
    @post = @topic.posts.build(:body => "test post body")
    @post.reader = readers(:normal)
    @post.save!
  end

  describe "on get to index" do
    before do
      get :index
    end

    it "should render the list of posts by date" do
      response.should be_success
      response.should render_template("index")
    end  
  end
    
  describe "on get to show" do
    before do

    end
    
    describe "for a page comment" do
      it "should redirect to the page address and post anchor" do
        
      end
    end
    
    describe "for a normal post" do
      it "should redirect to the topic address and post anchor" do
        
      end
    end
            
    if defined? MultiSiteExtension
      describe "for a post on another site" do
        it "should return a file not found error" do
          
        end
      end
    end
  end
  
  describe "on get to new" do
    describe "without a logged-in reader" do
      describe "over xmlhttp" do
        it "should render a bare login form for inclusion in the page" do

        end
      end
      describe "over normal http" do
        before do
          get :new
        end
        it "should redirect to login" do

        end
        it "should store the request address in the session" do

        end
      end
    end

    describe "without proper context" do
      it "should redirect to the topic list" do 
        
      end
      
      it "should flash an appropriate error" do 
        
      end
    end

    describe "over xmlhttp" do
      it "should render a bare comment form for inclusion in the page" do
        
      end
    end

    describe "over normal http" do
      it "should render the new post form in the normal way" do
        
      end
    end
  end

  describe "on post to create" do
    before do
      
    end
    
    describe "without a logged-in reader" do
      it "should redirect to login" do

      end
    end

    describe "without proper context" do
      it "should redirect to the topic index" do

      end
      it "should flash an appropriate error" do

      end
    end

    describe "without a message" do
      it "should re-render the post form" do

      end
      it "should flash an appropriate error" do

      end
    end

    describe "with a valid request" do
      it "should create the post" do
        
      end
      
      describe "over xmlhttp" do
        it "should return the formatted message for inclusion in the page" do
          
        end
      end

      describe "over normal http" do
        it "should redirect to the right topic page" do
        
        end
      end
    end

    if defined? MultiSiteExtension
      describe "when using multisite" do
        it "should not allow the creation of a post on another site" do
        
        end
      end
    end
  end
end
