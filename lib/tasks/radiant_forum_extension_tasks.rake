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
        
          database = ENV['database'] || 'vanilla'
          user = ENV['user'] || 'forum'
          password = ENV['password'] || ''
          Page.current_site = Site.find_by_id(ENV['site']) if ENV['site'] && defined? Site
        
          dbh = DBI.connect("DBI:Mysql:#{database}", user, password)
        
          dbh.select_all('select * from LUM_User') do | row |
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
              p "Imported forum #{forum.name}"
            end
          end
        
          posts = {}
          topic_posts = {}
          dbh.select_all('select * from LUM_Comment ORDER BY DateCreated ASC') do | row |
            posts[row['CommentID']] = row
            topic_posts[row['DiscussionID']] ||= []
            topic_posts[row['DiscussionID']].push(row)
          end
          
          p "*** importing topics"
          
          dbh.select_all('select * from LUM_Discussion') do | row |
            first_post = posts[row['FirstCommentID']] || topic_posts[row['DiscussionID']].shift
            forum = Forum.find_by_old_id(row['CategoryID'])
            raise "no forum for old id #{row['CategoryID']}. Go fix." unless forum
            if forum && first_post
              topic = forum.topics.build(
                :reader => Reader.find_by_old_id(row['AuthUserID']),
                :name => row['Name'],
                :body => first_post['Body'],
                :created_at => row['DateCreated'],
                :replied_at => topic_posts[row['DiscussionID']].last['DateCreated'],
                :sticky => row['Sticky'],
                :locked => row['Closed'],
                :replied_by => Reader.find_by_old_id(row['LastUserID']),
                :old_id => row['DiscussionID']
              )
                          
              begin
                if topic.save!
                  p "Imported topic #{topic.name}"
          
                  topic_posts[row['DiscussionID']].each do |post|
                    unless post['CommentID'] == row['FirstCommentID']          # first post is created in a pre-validation filter, so we can't check for its old_id
                      post = topic.posts.build(
                        :forum => forum,
                        :reader => Reader.find_by_old_id(post['AuthUserID']),
                        :created_at => post['DateCreated'],
                        :updated_at => post['DateEdited'],
                        :body => post['Body'],
                        :old_id => post['CommentID']
                      )
                      post.save
                    end
                  end
                  p "... with #{topic.posts.count} post" + (topic.posts.count == 1 ? '' : 's')
                end
              rescue ActiveRecord::RecordInvalid => e
                p "!!! failed to import topic #{row['DiscussionID']}: #{e.inspect}"
              end
              
            else
              p "skipping topic #{row['Name']}: no post"
            end
          end
        end
      end
    end
  end
end
