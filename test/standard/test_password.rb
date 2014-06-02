require "test_birst_command"

class Test_password < Test::Unit::TestCase

  def setup
    ENV['ENVCRYPT_KEY'] = '9Aqck/FZ0pCRkiw95VpxLw==$kxnYLOCo9qHDHHaTZM+fN73WVclDkRqO+uxSgzFzrpQ=$qoEtCm1BQWgc+WAxpotsrw=='

    @password = "mysecretpass"
    @encrypted = "MBTkxkMT8AbQupkOwtG9uQ=="
  end

  def teardown
  end

  def test_decrypt
    crypt = Envcrypt::Envcrypter.new
    assert_equal @password, crypt.decrypt(@encrypted), "Wrong decrypted password"
  end
end


