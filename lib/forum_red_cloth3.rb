module ForumRedCloth3

  def smilies(text)
    %w{angry smile bigsmile confused cool cry devil neutral sad shamed shocked surprised tongue wink }.each do |icon|
      imgtag = 
      text.gsub!(/:#{icon}:/, %{<img src="/images/emoticons/#{icon}.gif" alt="(#{icon})" class="smiley" />})
    end
  end

end
