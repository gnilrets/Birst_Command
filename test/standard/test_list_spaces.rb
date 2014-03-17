require "test_birst_command"

class Test_list_spaces < Test::Unit::TestCase

  def setup
    Birst_Command::Config.read_config
  end

  def teardown
  end

  def test_login

    client = Savon.client do
      wsdl Birst_Command::Config.options[:wsdl]
      endpoint Birst_Command::Config.options[:endpoint]
      convert_request_keys_to :none
      soap_version 1
      pretty_print_xml true
      filters [:password]
    end

    response = client.call(:login) do
      message username: Birst_Command::Config.options[:username], 
              password: Obfuscate.deobfuscate(Birst_Command::Config.options[:password])
    end

    auth_cookies = response.http.cookies
    token = response.hash[:envelope][:body][:login_response][:login_result]

    response = client.call(:list_spaces, cookies: auth_cookies) do
      message token: "#{token}"
    end

    spaces = response.hash[:envelope][:body][:list_spaces_response][:list_spaces_result][:user_space]
    spaces.each { |space| puts space }

    response = client.call(:logout, cookies: auth_cookies) do
      message token: "#{token}"
    end

  end
end


