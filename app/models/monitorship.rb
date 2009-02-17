class Monitorship < ActiveRecord::Base
  belongs_to :reader
  belongs_to :topic
end
