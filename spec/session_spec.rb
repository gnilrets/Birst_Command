require 'savon/mock/spec_helper'

describe "Sessions" do
  include Savon::SpecHelper

  before { Settings.session.soap_log_level = :debug }

  shared_examples_for "Log in and out" do

    context "by calling the object methods directly" do
      specify "without options" do
        mysession = Session.new
        expect(mysession.login).to be_successful
        mysession.logout
      end

      specify "with options" do
        mysession = Session.new :soap_log_level => :error, :soap_logger => Logger.new(STDOUT)
        expect(mysession.login).to be_successful
        mysession.logout
      end
    end

    context "in a session block" do
      specify "without options" do
        Session.new do |bc|
        end
      end

      specify "with options" do
        Session.new :soap_log_level => :error, :soap_logger => Logger.new(STDOUT) do |bc|
        end
      end
    end
  end



  context "with mock objects" do
    before do
      savon.mock!
      crypt = Envcrypt::Envcrypter.new

      message = { :username => Settings.session.username, :password => crypt.decrypt(Settings.session.password) }
      savon.expects(:login).with(message: message).returns(BCSpecFixtures.login)
      savon.expects(:logout).with(message: { :token => BCSpecFixtures.login_token }).returns(BCSpecFixtures.logout)
    end

    after { savon.unmock! }

    it_behaves_like "Log in and out"
  end

  context "with live connection to BWS", :live => true do
    it_behaves_like "Log in and out"
  end
end
