module ForumRailsPage
  
  def cache?
    Radiant.config['forum.cached?']
  end

end
