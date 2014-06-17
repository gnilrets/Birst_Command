describe "Loading settings from YAML file", :focus => true do

  let(:test_password) { "Habedashery==" }

  before do
    ENV['BC_SPEC_PASSWORD'] = test_password

    file = File.join(File.dirname(__FILE__),"sample_settings.yaml")
    Birst_Command.load_settings_from_file(file)
  end

  it "should set the username from the file" do
    expect(Settings.session.username).to eq "ThisIsntARealUsername"
  end

  it "should use ERB to set the password" do
    expect(Settings.session.password).to eq test_password
  end
end
