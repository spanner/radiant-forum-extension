class MonitorshipsController < ApplicationController

  radiant_layout 'forum' 
  before_filter :find_user_if_admin

  def index
    @monitorships = @user.monitorships
    @topics = @monitorships.collect(&:topic)  # monitored_topics only includes active monitorings but here we want to switch on and off
  end

  def create
    @monitorship = Monitorship.find_or_initialize_by_user_id_and_topic_id(@user.id, params[:topic_id])
    @monitorship.update_attribute :active, true
    respond_to do |format| 
      format.html { redirect_to topic_path(params[:forum_id], params[:topic_id]) }
      format.js { render :layout => false }
      format.json { render :json => @monitorship.to_json }
    end
  end
  
  def destroy
    @monitorship = Monitorship.find_or_initialize_by_user_id_and_topic_id(@user.id, params[:topic_id])
    @monitorship.update_attribute :active, false
    respond_to do |format| 
      format.html { redirect_to topic_path(params[:forum_id], params[:topic_id]) }
      format.js { render :layout => false }
      format.json { render :json => @monitorship.to_json }
    end
  end

  private

    def find_user_if_admin
      @user = params[:id] && current_user.admin? ? User.find(params[:id]) : current_user
    end

end
