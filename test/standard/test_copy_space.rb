require "test_birst_command"

class Test_copy_space < Test::Unit::TestCase

  def setup
    Birst_Command::Config.read_config
    Birst_Command::Config.read_config(File.join(File.dirname(__FILE__),"../config_test.json"))
    @new_space_id = nil
  end

  def teardown
    Session.start do |bc|
      bc.delete_space :spaceId => @new_space_id
    end
  end

  def test_copy_space
    test_options = Birst_Command::Config.options[:test][:test_copy_space]

    Session.start do |bc|
      @new_space_id = bc.create_new_space :spaceName => "test_copy_space",
                                          :comments => "",
                                          :automatic => "false"
      puts "#{bc.list_spaces}"
    end

    assert_equal 36, @new_space_id.length, "Got an invalid space id #{@new_space_id}"
  end
end


