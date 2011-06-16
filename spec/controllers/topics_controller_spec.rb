require File.dirname(__FILE__) + '/../spec_helper'

describe TopicsController do
  dataset :forums

  before do
    Page.current_site = sites(:test) if defined? Site
    controller.stub!(:request).and_return(request)
    Radiant::Config['forum.public?'] = true
  end

  describe "on get to index" do
    describe "with html format" do
      before do
        get :index
      end
    
      it "should render the topic list" do
        response.should be_success
        response.should render_template("index")
      end
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
  end

end