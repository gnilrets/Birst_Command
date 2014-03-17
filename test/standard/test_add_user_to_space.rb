require "test_birst_command"

class Test_add_user_to_space < Test::Unit::TestCase

  def setup
    Birst_Command::Config.read_config
    Birst_Command::Config.read_config(File.join(File.dirname(__FILE__),"../config_test.json"))
  end

  def teardown
  end

  def test_add_user_to_space
    test_options = Birst_Command::Config.options[:test][:test_add_user_to_space]

    user_added = false
    Session.start do
      remove_user_from_space(username: test_options[:userName],
                             spaceid: test_options[:spaceID])
      add_user_to_space(username: test_options[:userName],
                        spaceid: test_options[:spaceID],
                        has_admin: false)
      user_added = list_users_in_space(spaceid: test_options[:spaceID]).include? test_options[:userName]
    end

    assert user_added, "User #{test_options[:userName]} not added!"
  end
end


