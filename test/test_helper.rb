require 'rubygems'
require 'test/unit'
require 'active_record'
require 'active_record/fixtures'
require 'mocha'
require 'yaml'

ActiveRecord::Base.configurations = YAML::load(File.open(File.join(TEST_ROOT,'database.yml')))
ActiveRecord::Base.establish_connection(:find_ids_test)

ActiveRecord::Schema.define do
  create_table "users", :force => true do |t|
    t.string    "username"
    t.string    "email"
    t.integer   "reverse"
    t.integer   "random"
  end
  
  create_table "wacky_users", :primary_key => 'wack', :force => true do |t|
    t.string   "username"
  end
end

class User < ActiveRecord::Base
  def after_initialize
    # for testing
  end
end

class WackyUser < ActiveRecord::Base
  set_primary_key 'wack'
end

(1..10).each do |i|
  User.create!(
    :username => "user#{i}",
    :email    => "user#{i}@gmail.com",
    :random   => rand(100000),
    :reverse  => 100000 - i
  )
  
  WackyUser.create(:username => "user#{i}")
end