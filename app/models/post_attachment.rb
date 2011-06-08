class PostAttachment < ActiveRecord::Base

  named_scope :imported, :conditions => "old_id IS NOT NULL"

  @@image_content_types = ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg']
  cattr_reader :image_content_types

  class << self
    def image?(content_type)
      image_content_types.include?(content_type)
    end
    
    def thumbnail_sizes
      { :icon => ['24x24#', :png], :thumbnail => ['100x100>', :png] }.merge(configured_styles)
    end
    
    def configured_styles
      styles = Radiant::Config["assets.additional_thumbnails"].gsub(/\s+/,'').split(',') if Radiant::Config["assets.additional_thumbnails"]
      styles.collect{|s| s.split('=')}.inject({}) {|ha, (k, v)| ha[k.to_sym] = v; ha}
    end
    
    def thumbnail_names
      thumbnail_sizes.keys
    end
  end

  belongs_to :post
  belongs_to :reader
  acts_as_list :scope => :post_id
  has_attached_file :file,
    :styles => lambda { |attachment| 
      if image_content_types.include? attachment.instance_read(:content_type)
        thumbnail_sizes
      else
        {}
      end
    },
    :whiny_thumbnails => false,
    :url => "/:class/:id/:basename:no_original_style.:extension",
    :path => ":rails_root/:class/:id/:basename:no_original_style.:extension"      # attachments can only be accessed through the PostAttachments controller, in case file security is required

  attr_protected :file_file_name, :file_content_type, :file_file_size
  validates_attachment_presence :file, :message => t('forum_extension.error.no_file')
  validates_attachment_content_type :file, :content_type => Radiant::Config["forum.attachment.content_types"].split(', ') if Radiant::Config.table_exists? && !Radiant::Config["forum.attachment.content_types"].blank?
  validates_attachment_size :file, :less_than => Radiant::Config["forum.attachment.max_size"].to_i.megabytes if Radiant::Config.table_exists? && Radiant::Config["forum.attachment.max_size"]

  named_scope :images, :conditions => ["file_content_type IN (#{image_content_types.map{'?'}.join(',')})", *image_content_types]
  named_scope :non_images, :conditions => ["file_content_type NOT IN (#{image_content_types.map{'?'}.join(',')})", *image_content_types]

  def image?
    self.class.image?(file_content_type)
  end
  
  def filename
    file_file_name
  end

  def basename
    File.basename(filename, ".*") if filename
  end

  def extension
    filename.split('.').last.downcase if filename
  end
  
  def thumbnail
    file.url(:thumbnail) if image?
  end
  
  def icon
    iconpath = Radiant::Config.table_exists? && Radiant::Config['forum.icon_path'] ? Radiant::Config['forum.icon_path'] : '/images/forum/icons'
    if image?
      file.url(:icon)
    else
      icon = File.join(RAILS_ROOT, 'public', iconpath, "#{extension}.png")
      if File.exists? icon
        "#{iconpath}/#{extension}.png"
      else
        "#{iconpath}/attachment.png"
      end
    end
  end

end
