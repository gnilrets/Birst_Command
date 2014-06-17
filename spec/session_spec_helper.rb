module SessionSpecHelper
  def mock_login_and_out(&block)
    crypt = Envcrypt::Envcrypter.new

    message = { :username => Settings.session.username, :password => crypt.decrypt(Settings.session.password) }
    savon.expects(:login).with(message: message).returns(BCSpecFixtures.login)
    yield if block_given?
    savon.expects(:logout).with(message: { :token => BCSpecFixtures.login_token }).returns(BCSpecFixtures.logout)
  end
end
