module Birst_Command
  class Session
    def initialize
      @options = Birst_Command::Config.options

      @client = Savon.client(
        wsdl: @options[:wsdl],
        endpoint: @options[:endpoint],
        convert_request_keys_to: :none,
        soap_version: 1,
        pretty_print_xml: true,
        filters: [:password]
      )

      @response = nil
      @token = nil
      @auth_cookies = nil
    end

    attr_reader :token
    attr_reader :auth_cookies
    attr_reader :response


    def self.start(&b)
      session = self.new

      session.login
      session.command(&b)
    ensure
      session.logout
    end


    def login
      @response = @client.call(:login,
        message: {
          username: @options[:username], 
          password: Obfuscate.deobfuscate(@options[:password])
        })

      @auth_cookies = @response.http.cookies
      @token = @response.hash[:envelope][:body][:login_response][:login_result]      
    end


    def logout
      @response = @client.call(:logout, 
        cookies: @auth_cookies,
        message: {
          token: @token
        })
    end


    def command(&b)
      yield self
    end


    def list_spaces
      @response = @client.call(:list_spaces,
        cookies: @auth_cookies,
        message: {
          token: @token
        })
      [@response.hash[:envelope][:body][:list_spaces_response][:list_spaces_result][:user_space]].flatten
    end


    def list_users_in_space(space_id: "NOTSET")
      @response = @client.call(:list_users_in_space,
        cookies: @auth_cookies,
        message: {
          token: @token,
          spaceID: space_id
        })
      [@response.hash[:envelope][:body][:list_users_in_space_response][:list_users_in_space_result][:string]].flatten
    end


    def add_user_to_space(username: "tom@myspace.com",space_id: "NOTSET",has_admin: false)
      @response = @client.call(:add_user_to_space, 
        cookies: @auth_cookies,
        message: {
          token: @token,
          userName: username,
          spaceID: space_id,
          hasAdmin: has_admin.to_s
        })
    end


    def remove_user_from_space(username: "tom@myspace.com",space_id: "NOTSET")
      @response = @client.call(:remove_user_from_space, 
        cookies: @auth_cookies,
        message: {
          token: @token,
          userName: username,
          spaceID: space_id
        })
    end

    def create_new_space(space_name: "NOTSET", comments: "", automatic: false)
      @response = @client.call(:create_new_space,
        cookies: @auth_cookies,
        message: {
          token: @token,
          spaceName: space_name,
          comments: "",
          automatic: automatic.to_s
        })
      @response.hash[:envelope][:body][:create_new_space_response][:create_new_space_result]
    end

    def delete_space(space_id: "NOTSET")
      @response = @client.call(:delete_space,
        cookies: @auth_cookies,
        message: {
          token: @token,
          spaceId: space_id,
        })
      @response.hash[:envelope][:body][:delete_space_response][:delete_space_result]
    end

  end
end
