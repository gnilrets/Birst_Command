module Birst_Command

  # Public: Session class used to interact with Birst Web Services
  class Session
    # Public: Initialize Session class
    #
    # wsdl     - URL of soap WSDL (default: Settings.session.wsdl)
    # endpoint - URL of soap endpoint (default: Settings.session.endpoint)
    # soap_log - Boolean switch indicating whether logging should be performed (default: Settings.session.soap_log)
    # soap_logger - Logger instance used to write log messages (default: Settings.session.soap_logger)
    # soap_log_level - Logging level (default: Settings.session.soap_log_level)
    # username - Username to use to login to Birst Web Services (default: Settings.session.username)
    # password - Encrypted password for username (default: Settings.session.password)
    #
    # Returns nothing
    def initialize(wsdl:           Settings.session.wsdl,
                   endpoint:       Settings.session.endpoint, 
                   soap_log:       Settings.session.soap_logger,
                   soap_logger:    Settings.session.soap_logger,
                   soap_log_level: Settings.session.soap_log_level,
                   username:       Settings.session.username,
                   password:       Settings.session.password
                   )

      @client = Savon.client(
        wsdl: wsdl,
        endpoint: endpoint,
        convert_request_keys_to: :none,
        soap_version: 1,
        pretty_print_xml: true,
        filters: [:password],
        logger: soap_logger,
        log_level: soap_log_level,
        log: soap_log
      )

      @username = username
      @password = decrypt(password)

      @response = nil
      @token = nil
      @auth_cookies = nil
    end

    attr_reader :token
    attr_reader :auth_cookies
    attr_reader :response


    def decrypt(password)
      crypt = Envcrypt::Envcrypter.new
      crypt.decrypt(password)
    end


    def self.start(use_cookie: nil, &b)
      session = self.new
      session.login(use_cookie: use_cookie)
      session.execute_block(&b)
    ensure
      session.logout
    end


    def login(use_cookie: nil)
      crypt = Envcrypt::Envcrypter.new

      @auth_cookies = use_cookie
      @response = @client.call(:login,
        cookies: @auth_cookies,
        message: {
          username: @username, 
          password: @password
        })

      @auth_cookies = @response.http.cookies if @auth_cookies.nil?
      @token = @response.hash[:envelope][:body][:login_response][:login_result]      
    end


    def execute_block(&b)
      yield self
    end


    def method_missing(command_name, *args)
      command command_name, *args
    end


    def command(command_name, *args)
      response_key = "#{command_name}_response".to_sym
      result_key = "#{command_name}_result".to_sym

      message = args.last.is_a?(Hash) ? args.pop : {}
      result = @client.call command_name,
                            cookies: @auth_cookies,
                            message: { :token => @token }.merge(message)

      result.hash[:envelope][:body][response_key][result_key]
    end
  end
end
