require "test_birst_command"

class Test_add_user_to_space < Test::Unit::TestCase

  def setup
    Birst_Command::Config.read_config
    Birst_Command::Config.read_config(File.join(File.dirname(__FILE__),"../config_test.json"))
    @test_options = Birst_Command::Config.options[:test][:test_add_user_to_space]
  end


  def teardown
  end


  def user_exists?
    result = nil
    Session.start do |bc|
      users = bc.list_users_in_space :spaceID => @test_options[:space_id]
      result = [users[:string]].flatten.include? @test_options[:username]
    end
    result
  end


  def test_add_user_to_space
    Session.start do |bc|
      bc.add_user_to_space :userName => @test_options[:username],
                           :spaceID => @test_options[:space_id],
                           :hasAdmin => "false"
    end

    assert user_exists?, "User #{@test_options[:username]} not added!"
  end


  def test_remove_user_from_space
    test_add_user_to_space if !user_exists?

    Session.start do |bc|
      bc.remove_user_from_space :userName => @test_options[:username],
                                :spaceID => @test_options[:space_id]
    end

    assert !user_exists?, "User #{@test_options[:username]} should no longer exist!"
  end
end


