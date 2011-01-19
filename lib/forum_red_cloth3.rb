module ForumRedCloth3

  def smilies(text)
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
			'B]' => 'cool',
		}

    # these are generally put in by the punymce toolbar, so we use their nasty but effective combination of blank image with sprite background
		text.gsub!(/(\:\)|\=\)|\:\||\=\||\:\(|\=\(|\:D|\=D|\:o|\:O|\=o|\=O|\;\)|\:\/|\=\/|\:P|\:p|\=P|\=p|\:\[|8\||\:0|8\])/) do |w| 
		  %{<img src="/images/furniture/blank.png" class="emoticon #{emoticons[w]}" />}; 
		end

    # old syntax inherited from vanilla
    text.gsub!(/\:(angry|smile|bigsmile|confused|cool|cry|devil|neutral|sad|shamed|shocked|surprised|tongue|wink)\:/) do |w| 
      %{<img src="/images/emoticons/#{w}.gif" alt="(#{w})" title="#{w}" class="smiley" />} 
    end
  end

end
