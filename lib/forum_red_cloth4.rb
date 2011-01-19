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
    
    Rails.logger.warn "!!! looking for smilies"
    
    emoticons = {
			':)' => 'happy',
			'=)' => 'happy',
			':|' => 'unhappy',
			'=|' => 'unhappy',
			':(' => 'sad',
			'=(' => 'sad',
			':D' => 'grin',
			'=D' => 'grin',
			':o' => 'surprised',
			':O' => 'surprised',
			'=o' => 'surprised',
			'=O' => 'surprised',
			';)' => 'wink',
			':/' => 'halfhappy',
			'=/' => 'halfhappy',
			':P' => 'tongue',
			':p' => 'tongue',
			'=P' => 'tongue',
			'=p' => 'tongue',
			':[' => 'mad',
			'8|' => 'shocked',
			':0' => 'lol',
			'B]' => 'cool'
		}

    # these are generally put in by the punymce toolbar, so we use their nasty but effective combination of blank image with sprite background
		text.gsub!(/(\:\)|\=\)|\:\||\=\||\:\(|\=\(|\:D|\=D|\:o|\:O|\=o|\=O|\;\)|\:\/|\=\/|\:P|\:p|\=P|\=p|\:\[|8\||\:0|8\])/) do |w| 
		  %{<img src="/images/furniture/blank.png" class="emoticon #{emoticons[w]}" />}; 
		end

    # old syntax inherited from vanilla
    text.gsub!(/\:(angry|smile|bigsmile|confused|cool|cry|devil|neutral|sad|shamed|shocked|surprised|tongue|wink)\:/) do |w| 
      %{<img src="/images/emoticons/#{$1}.gif" alt="(#{$1})" title="#{$1}" class="smiley" />} 
    end
    
  end
end
