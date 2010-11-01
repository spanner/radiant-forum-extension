namespace :radiant do
  namespace :extensions do
    namespace :forum do
      
      desc "Runs the migration of the Forum extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          ForumExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          ForumExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Forum to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[ForumExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(ForumExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end
      
      namespace :import do
        desc "Quick and dirty import from Vanilla."
        task :vanilla => :environment do
          require 'dbi'

          clear = ENV['clear'] || false
          if clear == 'true'
            p "*** deleting all forum data"
            Forum.delete_all
            Topic.delete_all
            Post.delete_all
          end
          
          database = ENV['database'] || 'vanilla'
          user = ENV['user'] || 'forum'
          password = ENV['password'] || ''
          host = ENV['host'] || '127.0.0.1'
          Page.current_site = Site.find_by_id(ENV['site']) if ENV['site'] && defined? Site
        
          p "*** connecting to #{database} database at #{host}"
          dbh = DBI.connect("DBI:Mysql:#{database}:#{host}", user, password)
        
          dbh.select_all('select * from LUM_User') do |row|
            begin
              reader = Reader.find_or_create_by_email(row['Email'])
              if reader.new_record?
                reader_name = [row['FirstName'], row['LastName']].join(' ')
                reader_name = row['Name'] if reader_name == ' '
                reader.update_attributes(
                  :old_id => row['UserID'],
                  :name => reader_name,
                  :login => row['Name'],
                  :last_login_ip => row['RemoteIp'],
                  :last_request_at => row['DateLastActive'],
                  :password => 'import',
                  :password_confirmation => 'import'
                )
                p "Imported reader #{reader.name} (#{reader.old_id})"
                reader.crypted_password = row['Password']
                reader.save!
              else
                reader.update_attribute( :old_id, row['UserID'] )
              end
            rescue ActiveRecord::RecordInvalid => e
              p "!!! failed to import person #{row['UserID']}: #{e.inspect}"
            end
          end

          p "*** importing forums"

          dbh.select_all('select * from LUM_Category') do | row |
            forum = Forum.find_or_create_by_old_id(row['CategoryID'])
            if forum.new_record?
              forum.update_attributes(
                :name => row['Name'],
                :description => row['Description'],
                :position => row['Priority']
              )
              p "Imported category #{forum.name}"
            end
          end
        
          posts = {}
          topic_posts = {}
          
          dbh.select_all('select * from LUM_Comment ORDER BY DateCreated ASC') do |row|
            hash = row.to_h
            posts[row['CommentID'].to_i] = hash
            topic_posts[row['DiscussionID'].to_i] ||= []
            topic_posts[row['DiscussionID'].to_i].push(hash)
          end
          
          p "*** importing topics"
          dbh.select_all('select * from LUM_Discussion ORDER BY DiscussionID ASC') do |row|
            old_id = row['DiscussionID'].to_i
            cat_id = row['CategoryID'].to_i
            fp_id = row['FirstCommentID'].to_i
            
            unless first_post = posts[fp_id]
              if topic_posts[old_id]
                first_post = topic_posts[old_id].shift
                p "! first post missing: shifted #{first_post['CommentID']} from stack."
              end
            end
            forum = Forum.find_by_old_id(cat_id)
            raise RuntimeError, "no forum for category id #{cat_id}. Go fix." unless forum
                        
            if forum && first_post
              topic = forum.topics.build(
                :reader => Reader.find_by_old_id(row['AuthUserID'].to_i),
                :name => row['Name'],
                :body => first_post['Body'],
                :created_at => row['DateCreated'],
                :sticky => row['Sticky'],
                :locked => row['Closed'],
                :old_id => row['DiscussionID']
              )
                          
              begin
                if topic.save!
                  p "Imported topic #{old_id}: #{topic.name}. posts to import: #{topic_posts[old_id].length}"
                  topic_posts[old_id].each do |post|
                    begin
                      unless post['CommentID'] == row['FirstCommentID']          # first_post is created in a pre-validation filter, so we can't check for its old_id
                        topic.posts.build(
                          :forum => forum,
                          :reader => Reader.find_by_old_id(post['AuthUserID'].to_i),
                          :created_at => post['DateCreated'],
                          :updated_at => post['DateEdited'],
                          :body => post['Body'],
                          :old_id => post['CommentID']
                        ).save!
                      end
                    rescue ActiveRecord::RecordInvalid => e
                      p "!!! failed to import post #{post['CommentID']}: #{e.inspect}"
                    end
                  end
                  p "... with #{topic.posts.count} post" + (topic.posts.count == 1 ? '' : 's')
                end
              rescue ActiveRecord::RecordInvalid => e
                p "!!! failed to import topic #{old_id}: #{e.inspect}"
                p "    (reader is #{topic.reader.inspect})"
                p "    (body is #{topic.body.inspect})"
              end
              
            else
              p "skipping topic #{row['Name']} (#{old_id}): no post"
            end
          end
        end
      end
    end
  end
end
