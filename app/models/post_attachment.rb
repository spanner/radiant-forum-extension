class PostAttachment < ActiveRecord::Base

  @@image_content_types = ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg']
  @@extra_content_types = { :audio => ['application/ogg'], :movie => ['application/x-shockwave-flash'], :pdf => ['application/pdf'] }.freeze
  cattr_reader :extra_content_types, :image_content_types

  class << self
    def image?(asset_content_type)
      image_content_types.include?(asset_content_type)
    end
    
    def movie?(asset_content_type)
      asset_content_type.to_s =~ /^video/ || extra_content_types[:movie].include?(asset_content_type)
    end
        
    def audio?(asset_content_type)
      asset_content_type.to_s =~ /^audio/ || extra_content_types[:audio].include?(asset_content_type)
    end
    
    def pdf?(asset_content_type)
      extra_content_types[:pdf].include? asset_content_type
    end

    def other?(asset_content_type)
      ![:image, :movie, :audio].any? { |a| send("#{a}?", asset_content_type) }
    end

    def thumbnail_sizes
      if Radiant::Config.table_exists? && Radiant::Config["assets.additional_thumbnails"]
        thumbnails = Radiant::Config["assets.additional_thumbnails"].split(', ').collect{|s| s.split('=')}.inject({}) {|ha, (k, v)| ha[k.to_sym] = v; ha}
      else
        thumbnails = {}
      end
      thumbnails[:icon] = ['24x24#', :png]
      thumbnails[:thumbnail] = ['100x100>', :png]
      thumbnails
    end
    
    def thumbnail_names
      thumbnail_sizes.keys
    end
  end

  belongs_to :post
  belongs_to :reader
  acts_as_list :scope => :post_id
  has_attached_file :file,
                    :styles => thumbnail_sizes,
                    :whiny_thumbnails => false,
                    :url => "/:class/:id/:basename:no_original_style.:extension",
                    :path => ":rails_root/public/:class/:id/:basename:no_original_style.:extension"

  attr_protected :file_file_name, :file_content_type, :file_file_size
  validates_attachment_presence :file, :message => "You must choose a file to upload!"
  validates_attachment_content_type :file, :content_type => Radiant::Config["forum.attachment_content_types"].split(', ') if Radiant::Config.table_exists? && Radiant::Config["forum.attachment_content_types"]
  validates_attachment_size :file, :less_than => Radiant::Config["forum.max_attachment_size"].to_i.megabytes if Radiant::Config.table_exists? && Radiant::Config["forum.max_attachment_size"]

  def filename
    file_file_name
  end

  def basename
    File.basename(file_file_name, ".*") if file_file_name
  end

  def extension
    file_file_name.split('.').last.downcase if file_file_name
  end

  [:movie, :audio, :image, :other, :pdf].each do |content|
    define_method("#{content}?") { self.class.send("#{content}?", file_content_type) }
  end
  
  def type
    [:movie, :audio, :image, :other, :pdf].detect {|content| send("#{content}?")}
  end
  
  def icon
    iconpath = Radiant::Config.table_exists? && Radiant::Config['forum.icon_path'] ? Radiant::Config['forum.icon_path'] : '/images/icons/24'
    if image?
      return file.url(:icon)
    elsif pdf?
      return "#{iconpath}/pdf.png"
    elsif audio?
      return "#{iconpath}/audio.png"
    elsif movie?
      return "#{iconpath}/movie.png"
    else
      return "#{iconpath}/other.png"
    end
  end

end
