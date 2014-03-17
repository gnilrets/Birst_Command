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
      remove_user_from_space(username: test_options[:username],
                             space_id: test_options[:space_id])
      add_user_to_space(username: test_options[:username],
                        space_id: test_options[:space_id],
                        has_admin: false)
      user_added = list_users_in_space(space_id: test_options[:space_id]).include? test_options[:username]
    end

    assert user_added, "User #{test_options[:username]} not added!"
  end
end


