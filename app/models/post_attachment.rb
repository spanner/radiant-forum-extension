class PostAttachment < ActiveRecord::Base

  @@image_content_types = ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg']
  cattr_reader :image_content_types

  class << self
    def image?(content_type)
      image_content_types.include?(content_type)
    end
    
    def thumbnail_sizes
      if Radiant::Config.table_exists? && Radiant::Config["assets.additional_thumbnails"]
        thumbnails = Radiant::Config["assets.additional_thumbnails"].split(', ').collect{|s| s.split('=')}.inject({}) {|ha, (k, v)| ha[k.to_sym] = v; ha}
      else
        thumbnails = {}
      end
      thumbnails.merge({
        :icon => ['24x24#', :png],
        :thumbnail => ['100x100>', :png]
      })
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
    
  def icon
    iconpath = Radiant::Config.table_exists? && Radiant::Config['forum.icon_path'] ? Radiant::Config['forum.icon_path'] : '/images/forum/icons'
    if image?
      return file.url(:icon)
    else
      icon = File.join(RAILS_ROOT, 'public', iconpath, "#{extension}.png")
      logger.warn "!!  looking for #{icon}"
      if File.exists? icon
        "#{iconpath}/#{extension}.png"
      else
        "#{iconpath}/attachment.png"
      end
    end
  end

end
