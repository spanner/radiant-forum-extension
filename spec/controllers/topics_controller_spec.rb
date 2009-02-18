require File.dirname(__FILE__) + '/../spec_helper'
Radiant::Config['reader.layout'] = 'Main'

describe TopicsController do
  dataset :layouts
  dataset :topics
  dataset :forum_readers

  describe "on get to index" do
    before do
      get :index, :forum_id => forum_id(:public)
    end

    it "should redirect to the forum page" do
      response.should be_redirect
      response.should redirect_to(forum_url(forums(:public)))
    end  
  end
    
  describe "on get to show" do
    before do
      @topic = topics(:older)
      get :show, :id => topic_id(:older), :forum_id => forum_id(:public)
    end
    
    it "should render the show template" do
      response.should be_success
      response.should render_template("show")
    end
        
    if defined? MultiSiteExtension
      describe "when using multisite" do
        it "should  show a topic from this site" do
          
        end
        it "should not show a topic from another site" do
          
        end
      end
    end
  end
  
  describe "on get to new" do
    describe "without a logged-in reader" do
      before do
        reader_logout
        get :new, :forum_id => forum_id(:public)
      end
      it "should redirect to login" do
        response.should be_redirect
        response.should redirect_to(reader_login_url)
      end
      it "should store the return address in the session" do
        request.session[:return_to].should == request.request_uri
      end
    end

    describe "with a logged-in reader" do
      before do
        reader_login_as(:normal)
        get :new, :forum_id => forum_id(:public)
      end
      it "should render the new topic form" do
        response.should be_success
        response.should render_template("new")
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

    describe "with a logged-in reader" do
      describe "but an invalid request" do
        it "should rerender the topic form" do
          
        end
      end

      describe "and a valid request" do
        it "should create the topic" do
          
        end
        it "should redirect to the topic page" do
          
        end
      end
    end
    
    if defined? MultiSiteExtension
      describe "on another site" do
        it "should redirect to the topics index" do
        
        end
        it "should flash an appropriate error" do
          
        end
      end
    end
  end



end
