require File.join(File.dirname(__FILE__), '..', 'test', 'test_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'find_ids')
require 'benchmark'

ActiveRecord::Schema.define do
  create_table "junk_bins", :force => true do |t|
    t.string    "username"
    t.string    "email"
    t.text      "life_story"
    t.text      "excuses"
    t.text      "future_plans"
  end
end

class JunkBin < ActiveRecord::Base; end
  
100.times do
  JunkBin.create!(
    :username     => "user",
    :email        => "sameguy@gmail.com",
    :life_story   => 'a' * 2000,
    :excuses      => 'b' * 200,
    :future_plans => 'c' * 000
  )
end

# benchmarking with Wristband because User has that nasty after_initialize which slows things down
Benchmark.bmbm do |x|
  x.report('find(:all).map') { 10000.times { JunkBin.find(:all).map(&:id) } }
  x.report('find(:all, :select).map') { 10000.times { JunkBin.find(:all, :select => 'id').map(&:id) } }
  x.report('find_ids') { 10000.times { JunkBin.find_ids } }
end
