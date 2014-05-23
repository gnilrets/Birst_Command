require "test_birst_command"

class Test_password < Test::Unit::TestCase

  def setup
    ENV['BIRST_COMMAND_IV']   = "3Ez9fL0Jlt/E1d7QlVtKdw=="
    ENV['BIRST_COMMAND_KEY']  = "N589Xi0YzzkE+bRGwp3yaoVk/lneYsLHdFP+366hwcY="
    ENV['BIRST_COMMAND_SALT'] = "AUkJj8QSmNW3QazpyNl7og=="

    @password = "mysecretpass"
    @encrypted = "dP5+BfQyTAvKOM6s1ik4zg=="
  end

  def teardown
  end

  def test_key_generation
    ENV['BIRST_COMMAND_IV']   = nil
    ENV['BIRST_COMMAND_KEY']  = nil
    ENV['BIRST_COMMAND_SALT'] = nil

    Password.generate_keys

    encrypted = Password.encrypt(@password)
    decrypted = Password.decrypt(encrypted)

    assert_equal @password, decrypted, "Wrong decrypted password"
  end


  def test_decryption_failure
    Password.generate_keys

    encrypted = Password.encrypt(@password)
    ENV['BIRST_COMMAND_SALT'] = SecureRandom.base64

    assert_raise OpenSSL::Cipher::CipherError do
      decrypted = Password.decrypt(encrypted)
    end
  end


  def test_encrypt
    assert_equal @encrypted, Password.encrypt(@password), "Expecting encrypted password #{@encrypted}"
  end

  def test_decrypt
    assert_equal @password, Password.decrypt(@encrypted), "Expecting decrypted password #{@password}"
  end


end


