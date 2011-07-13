module ForumReadersController
  def self.included(base)
    base.class_eval do
      helper :forum
    end
  end
end
