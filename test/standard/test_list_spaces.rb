require "test_birst_command"

class Test_list_spaces < Test::Unit::TestCase

  def setup
    Birst_Command::Config.read_config
  end

  def teardown
  end

  def test_list_spaces
    spaces = nil
    Session.start do
      list_spaces.each { |space| puts space }
      spaces = list_spaces
    end

    assert spaces.is_a?(Array), "Expecting spaces to be an array"
    assert spaces[0].is_a?(Hash), "Expecting spaces to be an array of hashes"
  end
end


