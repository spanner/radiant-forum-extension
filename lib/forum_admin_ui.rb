module ForumAdminUI

 def self.included(base)
   base.class_eval do

      attr_accessor :forum, :topic, :post
      alias_method :forums, :forum
      alias_method :topics, :topic
      alias_method :posts, :post

      def load_forum_extension_regions
        @forum = load_default_forum_regions
        @topic = load_default_topic_regions
        @post = load_default_post_regions
      end

      def load_default_regions_with_forum
        load_default_regions_without_forum
        load_forum_extension_regions
      end
      alias_method_chain :load_default_regions, :forum

      protected

        def load_default_forum_regions
          OpenStruct.new.tap do |forum|
            forum.edit = Radiant::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{edit_header edit_form}
              edit.form.concat %w{edit_name edit_description edit_group}
              edit.form_bottom.concat %w{edit_buttons}
            end
            forum.index = Radiant::AdminUI::RegionSet.new do |index|
              index.thead.concat %w{title_header description_header latest_header modify_header}
              index.tbody.concat %w{title_cell description_cell latest_cell modify_cell}
              index.bottom.concat %w{buttons}
            end
            forum.remove = forum.index
            forum.new = forum.edit
          end
        end

        def load_default_topic_regions
          OpenStruct.new.tap do |topic|
            topic.edit = Radiant::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{edit_header edit_form}
              edit.form.concat %w{edit_name edit_body}
              edit.form_bottom.concat %w{edit_buttons}
            end
            topic.index = Radiant::AdminUI::RegionSet.new do |index|
              index.thead.concat %w{title_header date_header author_header body_header modify_header}
              index.tbody.concat %w{title_cell date_cell author_cell body_cell modify_cell}
              index.bottom.concat %w{buttons}
            end
            topic.remove = topic.index
            topic.new = topic.edit
          end
        end

        def load_default_post_regions
          OpenStruct.new.tap do |post|
            post.edit = Radiant::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{edit_header edit_form}
              edit.form.concat %w{show_name edit_body}
              edit.form_bottom.concat %w{edit_buttons}
            end
            post.index = Radiant::AdminUI::RegionSet.new do |index|
              index.thead.concat %w{body_header author_header topic_header modify_header}
              index.tbody.concat %w{body_cell author_cell topic_cell modify_cell}
              index.bottom.concat %w{buttons}
            end
            post.remove = post.index
            post.new = post.edit
          end
        end
      
    end
  end
end

