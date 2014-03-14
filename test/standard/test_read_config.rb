require "test_birst_command"

class Test_read_config < Test::Unit::TestCase

  def setup
  end

  def teardown
  end

  def test_read_config
    BCConfig.read_config(File.join(File.dirname(__FILE__),"config_test.json"))
    assert_equal "name@myplace.com", BCConfig.options[:username], "Error with config file"
  end

end


