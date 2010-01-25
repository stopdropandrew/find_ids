require 'find_ids'

ActiveRecord::Base.class_eval do
  include Insert
end
