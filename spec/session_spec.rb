describe "Sessions" do
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


  shared_examples_for "list spaces" do
    describe "list spaces" do
      it "should list spaces" do
        spaces = nil
        Session.new do |bc|
          spaces = bc.list_spaces
        end

        expect(spaces[:user_space].length).to be > 0
      end
    end
  end

  shared_examples_for "list users in space" do
    describe "list users in space" do
      it "should list the users in the space" do
        users = nil
        Session.new do |bc|
          users = bc.list_users_in_space :spaceID => spaceID
        end

        expect(users[:string].length).to be > 0
      end
    end
  end



  context "with mock objects" do

    before { savon.mock! }
    after { savon.unmock! }

    context "mock log in and out" do
      before { mock_login_and_out }
      it_behaves_like "Log in and out"
    end

    context "mock list spaces" do
      before do
        mock_login_and_out { savon.expects(:list_spaces).with(message: { :token => BCSpecFixtures.login_token }).returns(BCSpecFixtures.list_spaces) }
      end
      it_behaves_like "list spaces"
    end

    context "mock list users in spaces" do
      let(:spaceID) { "b7f3df39-438c-4ec7-bd29-489f41afde14" }
      before do
        message = { :token => BCSpecFixtures.login_token, :spaceID => spaceID }
        mock_login_and_out { savon.expects(:list_users_in_space).with(message: message).returns(BCSpecFixtures.list_users_in_space) }
      end
      it_behaves_like "list users in space"
    end
  end

  context "with live connection to BWS", :live => true do
    it_behaves_like "Log in and out"
    it_behaves_like "list spaces"

    let(:spaceID) do
      spaces = nil
      Session.new { |bc| spaces = bc.list_spaces }
      spaces[:user_space][0][:id]
    end
    it_behaves_like "list users in space"
  end

end
