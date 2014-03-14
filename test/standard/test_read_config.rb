require "test_birst_command"

class Test_read_config < Test::Unit::TestCase

  def setup
    BCConfig.config_full_path = File.join(File.dirname(__FILE__),"config_test.json")
  end

  def teardown
  end

  def test_read_config
    BCConfig.read_config
    assert_equal "name@myplace.com", BCConfig.options[:username], "Error with config file"
  end

end


