namespace :radiant do
  namespace :extensions do
    namespace :radiant_forum do
      
      desc "Runs the migration of the RadiantForum extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          RadiantForumExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          RadiantForumExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Forum to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[RadiantForumExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(RadiantForumExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
