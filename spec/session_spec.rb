require 'savon/mock/spec_helper'

describe "starting a session" do
  include Savon::SpecHelper

  before do
    Settings.session.soap_log_level = :debug

    savon.mock!
  end

  after { savon.unmock! }

  it "should do something" do
    crypt = Envcrypt::Envcrypter.new

    message = { :username => Settings.session.username, :password => crypt.decrypt(Settings.session.password) }
    savon.expects(:login).with(message: message).returns(BCSpecFixtures.login)
#    savon.expects(:list_spaces).with(message: { :token => BCSpecFixtures.login_token }).returns(BCSpecFixtures.list_spaces)
    savon.expects(:logout).with(message: { :token => BCSpecFixtures.login_token }).returns(BCSpecFixtures.logout)


    mysession = Session.new
    mysession.login
    mysession.logout

#    bc = Session.new
#    bc.login
#    spaces = bc.list_spaces
#    bc.logout

#    Session.start do |bc|
#      bc.list_spaces
#    end.tap { |s| puts "#{JSON.pretty_generate s}" }

#    response = mysession.response
#    puts "Response: #{response}"
#    expect(response).to be_successful

  end

end
