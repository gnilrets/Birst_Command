require "test_birst_command"

class Test_deobfuscate < Test::Unit::TestCase

  def setup
    @pwd = "mysecretpass"
    @obs_pwd = "IQX4os6wCE7rl+JuSYL2Iw=="
  end

  def teardown
  end

  def test_obfuscate
    assert_equal @obs_pwd, Obfuscate.obfuscate(@pwd), "Expecting password #{@obs_pwd}"
  end

  def test_deobfuscate
    assert_equal @pwd, Obfuscate.deobfuscate(@obs_pwd), "Expecting password #{@pwd}"
  end

end


