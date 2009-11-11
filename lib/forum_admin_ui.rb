module ForumAdminUI

 def self.included(base)
   base.class_eval do

      attr_accessor :forum
      alias_method :forums, :forum

      def load_default_regions_with_forum
        load_default_regions_without_forum
        @forum = load_default_forum_regions
      end
      alias_method_chain :load_default_regions, :forum

      protected

        def load_default_forum_regions
          returning OpenStruct.new do |forum|
            forum.edit = Radiant::AdminUI::RegionSet.new do |edit|
              edit.main.concat %w{edit_header edit_form}
              edit.form.concat %w{edit_name edit_description}
              edit.form_bottom.concat %w{edit_timestamp edit_buttons}
            end
            forum.index = Radiant::AdminUI::RegionSet.new do |index|
              index.thead.concat %w{title_header latest_header modify_header}
              index.tbody.concat %w{title_cell latest_cell modify_cell}
              index.bottom.concat %w{new_button}
            end
            forum.remove = forum.index
            forum.new = forum.edit
          end
        end
      
    end
  end
end

