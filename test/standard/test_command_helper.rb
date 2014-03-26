require "test_birst_command"

class Test_command_helper < Test::Unit::TestCase

  # Decided that commands should return whatever the Birst API returns.
  # However, for user code, it would be helpful to customize returns for
  # specific use cases

  class Session < Birst_Command::Session
    def list_spaces(*args)
      result = command __method__, *args
      [result[:user_space]].flatten
    end 
    def list_users_in_space(*args)
      result = command __method__, *args
      [result[:string]].flatten
    end
 end


  def setup
    Birst_Command::Config.read_config
    Birst_Command::Config.read_config(File.join(File.dirname(__FILE__),"../config_test.json"))
  end

  def teardown
  end

  def test_add_user_to_space
    test_options = Birst_Command::Config.options[:test][:test_add_user_to_space]

    spaces = nil
    users = nil
    Session.start do |bc|
      spaces = bc.list_spaces
      users = bc.list_users_in_space :spaceID => test_options[:space_id]
    end

    assert spaces.is_a?(Array), "list_spaces helper did not return an array"
    assert !spaces[0].has_key?(:user_space), "list_spaces helper should not give :user_space"
  end
end


