module ForumRedCloth3

  def smilies(text)
    emoticons = {
			':)' => 'happy',
			':|' => 'neutral',
			':(' => 'sad',
			':D' => 'grin',
			':O' => 'surprised',
			';)' => 'wink',
			'}:)' => 'devil',
			':P' => 'tongue',
			':[' => 'mad',
			'8|' => 'shocked',
			':@' => 'lol',
			'B]' => 'cool'
		}

    # old syntax carried over from vanilla
    text.gsub!(/\:(angry|smile|bigsmile|confused|cool|cry|devil|neutral|sad|shamed|shocked|surprised|tongue|wink)\:/) do |w| 
      %{<img src="/images/emoticons/#{$1}.gif" alt="(#{$1})" title="#{$1}" class="smiley" />} 
    end

    # these are generally put in by the punymce toolbar, so we use their nasty but effective combination of blank image with sprite background
		text.gsub!(/(\}\:\)|\:\)|\:\||\:\(|\:D|\:O|\;\)|\:P|\:\@|8\||\:\[|B\])/) do |w| 
		  %{<img src="/images/furniture/blank.png" class="emoticon #{emoticons[w]}" />}; 
		end
  end
end
