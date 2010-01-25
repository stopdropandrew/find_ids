TEST_ROOT = File.dirname(__FILE__)
require File.join(TEST_ROOT, 'test_helper')

require File.join(TEST_ROOT, '..', 'lib', 'find_ids')

class FindIdsTest < ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  self.use_instantiated_fixtures  = false
  self.use_transactional_fixtures = true
  self.pre_loaded_fixtures = true
  
  def test_find_ids_should_do_the_obvious
    assert_equal User.find(:all).map(&:id), User.find_ids
  end
  
  def test_find_ids_shouldnt_instantiate_AR_objects
    expected_ids = User.find(:all).map(&:id)

    User.any_instance.expects(:after_initialize).never
    assert_equal expected_ids, User.find_ids
  end
  
  def test_find_ids_can_handle_ordering
    assert_equal User.find(:all, :order => 'random').map(&:id), User.find_ids(:order => 'random')
  end
  
  def test_find_column_values_should_do_the_obvious
    assert_equal User.find(:all).map(&:email), User.find_column_values('email')
  end
  
  def test_find_column_values_shouldnt_instantiate_AR_objects
    expected_emails = User.find(:all).map(&:email)

    User.any_instance.expects(:after_initialize).never
    assert_equal expected_emails, User.find_column_values('email')
  end
  
  def test_find_column_values_can_handle_ordering
    assert_equal User.find(:all, :order => 'random').map(&:email), User.find_column_values('email', :order => 'random')
  end
  
  def test_find_column_values_handles_distinct
    original_count = User.count
    original_emails = User.find(:all, :order => 'email').map(&:email)

    User.find(:all).each do |user|
      User.create!(:email => user.email)
    end

    assert_equal original_count * 2, User.count, "There should be double the users"
    assert_equal original_emails, User.find_column_values('email', :order => 'email', :distinct => true)
  end
  
  def test_find_ids_should_use_primary_key
    assert_equal WackyUser.find(:all).map(&:wack), WackyUser.find_ids
  end
  
  def test_find_set_ids
    assert_equal Set.new(User.find_ids), User.find_set_ids
  end
  
  def test_find_multiple_column_values
    assert_equal User.find(:all).map{ |u| {'id' => u.id, 'email' => u.email} }, User.find_multiple_column_values('id', 'email')
  end
end