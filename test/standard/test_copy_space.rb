require "test_birst_command"

class Test_copy_space < Test::Unit::TestCase

  def setup
    Birst_Command::Config.read_config
    Birst_Command::Config.read_config(File.join(File.dirname(__FILE__),"../config_test.json"))
    @new_space_id = nil
  end

  def teardown
    Session.start do |bc|
      bc.delete_space(space_id: @new_space_id)
    end
  end

  def test_add_user_to_space
    test_options = Birst_Command::Config.options[:test][:test_copy_space]

    Session.start do |bc|
      bc.list_spaces.each do |space|
        puts "SPACE: #{space}"
      end

      @new_space_id = bc.create_new_space(space_name:"TESTME")
    end

    assert_equal 36, @new_space_id.length, "Got an invalid space id #{@new_space_id}"
  end
end


