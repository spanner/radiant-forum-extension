require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController do
  dataset :forums
  
  before do
    Radiant::Config['forum.public?'] = true
  end

  describe "on get to index" do
    it "should render the index page" do
      get :index
      response.should be_success
      response.should render_template("index")
    end  
  end
    
  describe "on get to show" do
    describe "for a first post" do
      it "should redirect to the topic" do
        get :show, :id => post_id(:first)
        response.should be_redirect
        topic = topics(:older)
        response.should redirect_to(topic_path(topic))
      end
    end

    describe "for a reply" do
      it "should redirect to the topic with the page and anchor of the post" do
        get :show, :id => post_id(:second)
        response.should be_redirect
        topic = topics(:older)
        response.should redirect_to(topic_path(topic, {:page => posts(:second).page_when_paginated, :anchor => "post_#{posts(:second).id}"}))
      end
    end
    
    # some odd staleness happening here
    # describe "for a page comment" do
    #   it "should redirect to the page address and post anchor" do
    #     get :show, :id => post_id(:comment)
    #     response.should be_redirect
    #     response.should redirect_to(pages(:commentable).url + "?page=1##{posts(:comment).dom_id}")
    #   end
    # end
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
      
      describe "over xmlhttp" do
        before do
          xhr :get, :new, {:topic_id => topic_id(:older), :forum_id => forum_id(:public)}
        end

        it "should render a bare login form" do
          response.should be_success
          response.should render_template('reader_sessions/_login_form')
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
          get :new, :topic_id => topic_id(:locked), :forum_id => forum_id(:public)
        end
        
        it "should redirect to the topic page" do 
          response.should be_redirect
          topic = topics(:locked)
          response.should redirect_to(topic_path(topic))
        end
        
        it "should flash an appropriate message" do 
          flash[:error].should_not be_nil
          flash[:error].should =~ /locked/
        end
      end

      describe "over normal http" do
        before do
          get :new, :topic_id => topic_id(:older), :forum_id => forum_id(:public)
        end

        it "should render the new post form in the normal way" do
          response.should be_success
          response.should render_template("posts/new")
          response.layout.should == 'layouts/radiant'
        end
      end

      describe "over xmlhttp" do
        before do
          xhr :get, :new, :topic_id => topic_id(:older), :forum_id => forum_id(:public)
        end

        it "should render a bare reply form" do
          response.should be_success
          response.should render_template('topics/_reply')
          response.layout.should be_nil
        end
      end
    end
  end
  
  describe "on post to create" do
    describe "without a logged-in reader" do
      before do
        logout_reader
        post :create, :post => {:body => 'otherwise complete'}, :topic_id => topic_id(:older), :forum_id => forum_id(:public)
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
        describe "over normal http" do
          before do 
            post :create, :post => {:body => ''}, :topic_id => topic_id(:locked)
          end
          it "should redirect to the topic page" do 
            response.should be_redirect
            topic = topics(:locked)
            response.should redirect_to(topic_path(topic))
          end
          
          it "should flash an appropriate error" do 
            flash[:error].should_not be_nil
            flash[:error].should =~ /locked/
          end
        end
        describe "over xmlhttp" do
          before do
            xhr :post, :create, :post => {:body => 'otherwise complete'}, :topic_id => topic_id(:locked), :forum_id => forum_id(:public)
          end

          it "should render a bare 'locked' template" do
            response.should be_success
            response.should render_template('topics/_locked')
            response.layout.should be_nil
          end
        end
      end

      describe "with an invalid message" do
        describe "over normal http" do
          before do 
            post :create, :post => {:body => ''}, :topic_id => topic_id(:older), :forum_id => forum_id(:public)
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
            xhr :post, :create, :post => {:body => ''}, :topic_id => topic_id(:older), :forum_id => forum_id(:public)
          end

          it "should re-render the bare post form" do
            response.should be_success
            response.should render_template('posts/_form')
            response.layout.should be_nil
          end
        end
      end
    end
    
    describe "with a valid request" do
      before do
        login_as_reader(:normal)
      end

      describe "over normal http" do
        before do
          alphabet = ("a".."z").to_a
          @body = Array.new(64, '').collect{alphabet[rand(alphabet.size)]}.join
          post :create, :post => {:body => @body}, :topic_id => topic_id(:older), :forum_id => forum_id(:public)
          @post = Post.find_by_body(@body)
        end

        it "should create the post" do
          @post.should_not be_nil
        end

        it "should associate the post with its topic" do
          @post.topic.should == topics(:older)
        end

        it "should redirect to the right topic and page" do
          response.should be_redirect
          topic = topics(:older)
          response.should redirect_to(topic_path(topic, {:page => @post.page_when_paginated, :anchor => "post_#{@post.id}"}))
        end
      end

      describe "over xmlhttp" do
        before do
          xhr :post, :create, :post => {:body => 'test post body'}, :topic_id => topics(:older), :forum_id => forum_id(:public)
        end

        it "should return the formatted message for inclusion in the page" do
          response.should be_success
          response.should render_template('posts/_post')
          response.layout.should be_nil
        end
      end

      describe "to attach a comment to a page" do
        before do
          login_as_reader(:normal)
          Radiant::Cache.should_receive(:clear).at_least(:once).and_return(true)
          post :create, :post => {:body => "I ain't getting in no plane.", :page_id => page_id(:commentable)}
          @post = Post.find_by_body("I ain't getting in no plane.")
        end
        
        it "should create the post" do
          @post.should_not be_nil
        end

        it "should attach the post to the page" do
          @post.page.should == pages(:commentable)
        end

        it "should not associate the post with a topic" do
          @post.topic.should be_nil
        end
      end

      describe "to attach a comment to an uncommentable page" do
        before do
          login_as_reader(:normal)
          post :create, :post => {:body => "foo"}, :page_id => page_id(:uncommentable)
        end

        it "should grumble" do
          response.should be_redirect
          response.should redirect_to(pages(:uncommentable).url)
          flash[:error].should_not be_nil
        end
      end
      
      describe "to start a new topic" do
        before do
          login_as_reader(:normal)
          post :create, :post => {:body => "Madam, I would drink it.", :topic_attributes => {:name => "Winston, I would poison your tea.", :forum_id => forum_id(:public)}}
          @topic = Topic.find_by_name("Winston, I would poison your tea.")
          @post = Post.find_by_body("Madam, I would drink it.")
        end
        
        it "should create the joined topic and post" do
          @topic.should_not be_nil
          @post.should_not be_nil
          @post.topic.should == @topic
          @topic.posts.first.should == @post
        end
      end
    end
  end
end
