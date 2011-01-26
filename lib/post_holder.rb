module PostHolder
  def has_posts?
    posts.any?
  end

  def has_replies?
    posts.count > 1
  end
  
  def replies
    posts.except(posts.first)    # double query but therefore still chainable and paginatable
  end

  def reply_count
    posts.count - 1
  end
  
  def voices
    posts.distinct_readers.map(&:reader)
  end
  
  def voice_count
    posts.distinct_readers.count  #actually counting posts, but the total is the same
  end
  
  def other_voices
    voices - [posts.first.reader]
  end
  
  def other_voice_count
    voice_count - 1
  end

  def paged?
    Radiant::Config['forum.paginate_posts?'] && posts.count > posts_per_page
  end

  def posts_per_page
    (Radiant::Config['forum.posts_per_page'] || 25).to_i
  end
  
  def last_page
    (posts.count.to_f/posts_per_page.to_f).ceil.to_i
  end
  
  def page_for(post)
    return nil unless post.holder == self
    return 1 unless paged?
    position = posts.index(post) || posts.count + 1             # new post not always present in cached posts collection
    (position.to_f/posts_per_page.to_f).ceil.to_i
  end
end