require File.dirname(__FILE__) + '/../spec_helper'
Radiant::Config['reader.layout'] = 'Main'

describe PostsController do
  dataset :layouts
  dataset :posts
  
  before do
    Page.current_site = sites(:test) if defined? Site
    controller.stub!(:request).and_return(request)
    @forum = forums(:public)
    @topic = topics(:older)
    @post = posts(:first)
    @comment = posts(:comment)
  end

  describe "on get to index" do
    before do
      get :index
    end

    it "should render the index page" do
      response.should be_success
      response.should render_template("index")
    end  
  end
    
  describe "on get to show" do
    
    describe "for a page comment" do
      before do
        @comment = posts(:comment)
        @page = pages(:commentable)
        get :show, :id => post_id(:comment), :topic_id => topic_id(:comments), :forum_id => forum_id(:comments)
      end
      it "should redirect to the page address and post anchor" do
        response.should be_redirect
        response.should redirect_to(@page.url + "#comment_#{@comment.id}")
      end
    end
    
    describe "for a normal post" do
      before do
        get :show, :id => @post.id, :topic_id => @topic.id, :forum_id => @forum.id
      end
      it "should redirect to the topic address, post page and post anchor" do
        response.should be_redirect
        response.should redirect_to(topic_url(@topic.forum, @topic, {:page => @post.topic_page, :anchor => "post_#{@post.id}"}))
      end
    end

    if defined? Site
      describe "for a post on another site" do
        it "should raise a file not found error" do
          lambda { get :show, :id => post_id(:elsewhere), :topic_id => topic_id(:elsewhere), :forum_id => forum_id(:elsewhere) }.should raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
  
  describe "on get to new" do
    describe "without a logged-in reader" do
      before do
        logout_reader
      end

      describe "over normal http" do
        before do
          get :new, :topic_id => topic_id(:older), :forum_id => forum_id(:public)
        end
        
        it "should redirect to login" do
          response.should be_redirect
          response.should redirect_to(reader_login_url)
        end
        
        it "should store the request address in the session" do
          request.session[:return_to].should == request.request_uri
        end
      end
      
      describe "by xmlhttprequest" do
        before do
          xhr :get, :new, {:topic_id => topic_id(:older), :forum_id => forum_id(:public)}
        end

        it "should render a bare login form for inclusion in the page" do
          response.should be_success
          response.should render_template('readers/login')
          response.layout.should be_nil
        end
      end
    end

    describe "with a logged-in reader" do
      before do
        login_as_reader(:normal)
      end

      describe "but to a locked topic" do
        before do
          @topic.locked = true
          @topic.save!
          get :new, :topic_id => @topic.id, :forum_id => forum_id(:public)
        end
        
        it "should redirect to the topic page" do 
          response.should be_redirect
          response.should redirect_to(topic_url(@topic.forum, @topic))
        end
        
        it "should flash an appropriate message" do 
          flash[:notice].should_not be_nil
          flash[:notice].should =~ /locked/
        end
      end

      describe "over normal http" do
        before do
          get :new, :topic_id => @topic.id, :forum_id => forum_id(:public)
        end

        it "should render the new post form in the normal way" do
          response.should be_success
          response.should render_template("new")
          response.layout.should == 'layouts/radiant'
        end
      end

      describe "by xmlhttprequest" do
        before do
          xhr :get, :new, :topic_id => @topic.id, :forum_id => forum_id(:public)
        end

        it "should render a bare comment form for inclusion in the page" do
          response.should be_success
          response.should render_template('new')
          response.layout.should be_nil
        end
      end
    end
  end


  # describe "on post to preview" do
  #   describe "with a logged-in reader" do
  #     before do
  #       login_as_reader(:normal)
  #     end
  # 
  #     describe "but to a locked topic" do
  #       before do
  #         @topic.locked = true
  #         @topic.save!
  #         post :preview, :post => {:body => 'how do I look?'}, :topic_id => @topic.id, :forum_id => forum_id(:public)
  #       end
  #     
  #       it "should redirect to the topic page" do 
  #         response.should be_redirect
  #         response.should redirect_to(topic_url(@topic.forum, @topic))
  #       end
  #     
  #       it "should flash an error" do 
  #         flash[:notice].should_not be_nil
  #         flash[:notice].should =~ /locked/
  #       end
  #     end
  # 
  #     describe "over normal http" do
  #       before do
  #         post :preview, :post => {:body => 'how do I look?'}, :topic_id => @topic.id, :forum_id => forum_id(:public)
  #       end
  # 
  #       it "should render the preview form in the normal way" do
  #         response.should be_success
  #         response.should render_template("preview")
  #         response.layout.should == 'layouts/radiant'
  #       end
  #     end
  # 
  #     describe "by xmlhttprequest" do
  #       before do
  #         xhr :post, :preview, :post => {:body => 'how do I look?'}, :topic_id => @topic.id, :forum_id => forum_id(:public)
  #       end
  # 
  #       it "should return a bare preview for inclusion in the page" do
  #         response.should be_success
  #         response.should render_template('preview')
  #         response.layout.should be_nil
  #       end
  #     end
  #   end
  # end
  
  describe "on post to create" do
    describe "without a logged-in reader" do
      before do
        logout_reader
        post :create, :post => {:body => 'otherwise complete'}, :topic_id => @topic.id, :forum_id => forum_id(:public)
      end
      
      it "should redirect to login" do
        response.should be_redirect
        response.should redirect_to(reader_login_url)
      end
    end

    describe "with a logged-in reader" do
      before do
        login_as_reader(:normal)
      end

      describe "but to a locked topic" do
        before do
          @topic.locked = true
          @topic.save!
        end
        
        describe "over normal http" do
          before do 
            post :create, :post => {:body => ''}, :topic_id => @topic.id, :forum_id => forum_id(:public)
          end
          it "should redirect to the topic page" do 
            response.should be_redirect
            response.should redirect_to(topic_url(@topic.forum, @topic))
          end
          
          it "should flash an appropriate error" do 
            flash[:notice].should_not be_nil
            flash[:notice].should =~ /locked/
          end
        end
        describe "by xmlhttprequest" do
          before do
            xhr :post, :create, :post => {:body => 'otherwise complete'}, :topic_id => @topic.id, :forum_id => forum_id(:public)
          end

          it "should render a bare 'locked' template for inclusion in the page" do
            response.should be_success
            response.should render_template('locked')
            response.layout.should be_nil
          end
        end
      end

      describe "with an invalid message" do
        describe "over normal http" do
          before do 
            post :create, :post => {:body => ''}, :topic_id => @topic.id, :forum_id => forum_id(:public)
          end
          
          it "should re-render the post form with layout" do
            response.should be_success
            response.should render_template('new')
            response.layout.should_not be_nil
          end
          
          it "should grumble" do
            flash[:error].should_not be_nil
          end
        end
        
        describe "over xmlhttp" do
          before do
            xhr :post, :create, :post => {:body => ''}, :topic_id => @topic.id, :forum_id => forum_id(:public)
          end

          it "should re-render the bare post form" do
            response.should be_success
            response.should render_template('new')
            response.layout.should be_nil
          end
          
        end
      end
    end
    
    describe "with a valid request" do
      before do
        login_as_reader(:normal)
      end

      it "should create the post" do
        post :create, :post => {:body => 'test post body'}, :topic_id => @topic.id, :forum_id => forum_id(:public)
        topic = Topic.find(@topic.id)
        topic.should_not be_nil
        topic.posts[-1].body.should == 'test post body'
      end
      
      describe "over xmlhttp" do
        before do
          xhr :post, :create, :post => {:body => 'test post body'}, :topic_id => @topic.id, :forum_id => forum_id(:public)
        end
        it "should return the formatted message for inclusion in the page" do
          response.should be_success
          response.should render_template('show')
          response.layout.should be_nil
        end
      end

      describe "over normal http" do
        before do
          alphabet = ("a".."z").to_a
          body = Array.new(64, '').collect{alphabet[rand(alphabet.size)]}.join
          post :create, :post => {:body => body}, :topic_id => @topic.id, :forum_id => forum_id(:public)
          @post = Post.find_by_body(body)
        end

        it "should redirect to the right topic and page" do
          response.should be_redirect
          response.should redirect_to(topic_url(@forum, @topic, {:page => @post.topic_page, :anchor => "post_#{@post.id}"}))
        end
      end

      describe "to attach a comment to a page" do
        it "should uncache the page" do

        end
      end
    end
  end
end
