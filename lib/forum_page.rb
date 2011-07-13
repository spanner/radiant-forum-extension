module ForumPage

  def self.included(base)
    base.class_eval {
      has_comments

      named_scope :busiest, lambda { |count| {
        :select => "pages.*, count(posts.id) AS post_count", 
        :joins => "INNER JOIN posts ON posts.page_id = pages.id",
        :group => column_names.map { |n| 'pages.' + n }.join(','),
        :order => "post_count DESC",
        :limit => count
      }}
      
      include InstanceMethods
    }
  end

  module InstanceMethods     
    
    def show_comments?
      !virtual? && !self.is_a?(RailsPage) && commentable?
    end
    
    # commentable? is a boolean model column
    def still_commentable?
      return false if virtual? or self.is_a? RailsPage
      return false unless Radiant::Config['forum.allow_page_comments?'] && commentable?
      return false if comments_closed?
      return true unless commentable_period && commentable_period > 0
      return Time.now - self.published_at < commentable_period
    end
    
    def locked?
      !still_commentable?
    end

  private
  
    def commentable_period
      Radiant::Config['forum.commentable_period'].to_i.days if Radiant::Config['forum.commentable_period']
    end

  end
end
