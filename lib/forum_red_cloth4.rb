module ForumRedCloth4
  
  def self.included(base)
    # base.extend ClassMethods
    base.class_eval do
      def to_html_with_smilies(*rules)
        rules.push(:smilies) unless rules.include?(:smilies)
        to_html_without_smilies(*rules)
      end
      alias_method_chain :to_html, :smilies unless self.instance_methods.include?("to_html_without_smilies")
    end
  end
  
  def smilies(text)
    %w{angry smile bigsmile confused cool cry devil neutral sad shamed shocked surprised tongue wink }.each do |icon|
      imgtag = 
      text.gsub!(/:#{icon}:/, %{<img src="/images/emoticons/#{icon}.gif" alt="(#{icon})" title="#{icon}" class="smiley" />})
    end
  end

end
