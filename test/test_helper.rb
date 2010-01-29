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
    t.integer   "counter"
  end
  
  create_table "wristbands", :primary_key => 'pkey', :force => true do |t|
    t.integer  "pkey"
    t.integer  "user_id"
  end
end

class Test::Unit::TestCase
  def assert_same_elements enum1, enum2, *args
    message = args.last.kind_of?(String) ? args.pop : "Expected Array #{enum1.inspect} to have same elements as #{enum2.inspect}."
    assert_block(build_message(message, "<?> expected to have the same elements as \n<?>.\n", enum2, enum1)) do
      if enum1.first.respond_to?(:<=>)
        enum1.sort == enum2.sort
      else
        enum1 == enum2
      end
    end
  end
end

class User < ActiveRecord::Base
  has_many :wristbands

  named_scope :less_than_five, :conditions => 'counter < 5'

  def after_initialize
    # for testing
  end
end

class Wristband < ActiveRecord::Base
  set_primary_key 'pkey'

  belongs_to :user
end

(1..10).each do |i|
  User.create!(
    :username => "user#{i}",
    :email    => "user#{i}@gmail.com",
    :random   => rand(100000),
    :reverse  => 100000 - i,
    :counter  => i
  )
  
  Wristband.create(:user_id => i)
  Wristband.create(:user_id => i)
end