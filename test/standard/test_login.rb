require "test_birst_command"

class Test_login < Test::Unit::TestCase

  def setup
    Birst_Command::Config.read_config
  end

  def teardown
  end

  def test_login
    token = ""
    Session.start do
      token = @token
    end

    assert_equal 32, token.length, "Got an invalid token #{token}"
  end

  def test_login_arg
    token = ""
    Session.start do |s|
      token = s.token
    end

    assert_equal 32, token.length, "Got an invalid token #{token}"
  end

end


