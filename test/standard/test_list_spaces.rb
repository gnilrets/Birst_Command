require "test_birst_command"

class Test_list_spaces < Test::Unit::TestCase

  def setup
    Birst_Command::Config.read_config
  end

  def teardown
  end

  def test_list_spaces
    spaces = nil
    Session.start do |bc|
      unclean_spaces = bc.list_spaces
      spaces = [unclean_spaces[:user_space]].flatten
    end

    assert spaces.is_a?(Array), "Expecting spaces to be an array"
    assert spaces[0].is_a?(Hash), "Expecting spaces to be an array of hashes"
  end
end


