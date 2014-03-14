require "test_birst_command"

class Test_logon < Test::Unit::TestCase

  def setup
    BCConfig.read_config
  end

  def teardown
  end

  def test_login

    client = Savon.client do
      wsdl BCConfig.options[:wsdl]
      endpoint BCConfig.options[:endpoint]
      convert_request_keys_to :none
      soap_version 1
      pretty_print_xml true
      filters [:password]
    end

    response = client.call(:login) do
      message username: BCConfig.options[:username], 
              password: Obfuscate.deobfuscate(BCConfig.options[:password])
    end

    auth_cookies = response.http.cookies
    token = response.hash[:envelope][:body][:login_response][:login_result]

    response = client.call(:logout, cookies: auth_cookies) do
      message token: "#{token}"
    end

#    assert_equal "name@myplace.com", BCConfig.options[:username], "Error with config file"
  end

end


