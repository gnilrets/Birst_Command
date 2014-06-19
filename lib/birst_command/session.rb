module Birst_Command

  # Public: Session class used to interact with Birst Web Services
  class Session

    # Public: Initialize Session class
    #
    # wsdl           - URL of soap WSDL (default: Settings.session.wsdl)
    # endpoint       - URL of soap endpoint (default: Settings.session.endpoint)
    # soap_log       - Boolean switch indicating whether logging should be performed (default: Settings.session.soap_log)
    # soap_logger    - Logger instance used to write log messages (default: Settings.session.soap_logger)
    # soap_log_level - Logging level (default: Settings.session.soap_log_level)
    # username       - Username to use to login to Birst Web Services (default: Settings.session.username)
    # password       - Encrypted password for username (default: Settings.session.password)
    # auth_cookie    - Use a previously generated authorization cookie
    #
    # Returns nothing
    def initialize(opts = {}, &block)
      @login_token = nil
      @options = set_options(opts)
      @client = new_client

      if block_given?
        login_and_run(&block)
      end
    end

    attr_reader :login_token
    attr_reader :auth_cookie


    # Public: Login to Birst using the username and password.  After login,
    # the auth cookie and login token are captured and stored as an instance
    # variable.
    #
    # Returns the Savon response.
    def login
      response = @client.call(:login,
        cookies: @auth_cookie,
        message: {
          username: @username, 
          password: decrypt(@password)
        })

      @auth_cookie = response.http.cookies if @auth_cookie.nil?
      @login_token = response.hash[:envelope][:body][:login_response][:login_result]
      response
    end

    # Public: Method missing used to send commands to Birst Web Services.
    #
    # command_name - Symbol representing the name of the Birst command (snake_case)
    # *args - Optional arguments that are passed to the Birst command.
    #
    # Returns - The soap result as a hash
    def method_missing(command_name, *args)
      command command_name, *args
    end

    # Public: Runs the command that is obtained from the method_missing call.
    #
    # command_name - Name of Birst command (snake_case).
    # *args - Optional arguments that are passed to the Birst command.
    #
    # Returns - The soap result as a hash
    def command(command_name, *args)
      response_key = "#{command_name}_response".to_sym
      result_key = "#{command_name}_result".to_sym

      message = args.last.is_a?(Hash) ? args.pop : {}
      result = @client.call command_name,
                            cookies: @auth_cookie,
                            message: { :token => @login_token }.merge(message)

      result.hash[:envelope][:body][response_key][result_key]
    end

    private

    # Private: Reads in an options hash and applies global default Settings
    # if applicable.  Options are converted into instance variables.
    #
    # Returns nothing.
    def set_options(opts = {})
      @wsdl           = opts[:wsdl]           || Settings.session.wsdl
      @endpoint       = opts[:endpoint]       || Settings.session.endpoint
      @soap_log       = opts[:soap_log]       || Settings.session.soap_log
      @soap_logger    = opts[:soap_logger]    || Settings.session.soap_logger
      @soap_log_level = opts[:soap_log_level] || Settings.session.soap_log_level
      @username       = opts[:username]       || Settings.session.username
      @password       = opts[:password]       || Settings.session.password
      @auth_cookie    = opts[:auth_cookie]    || nil
    end


    # Private: Create a new Savon SOAP client.
    #
    # Returns a Savon instance configured with options specified in initialize.
    def new_client
      Savon.client(
        wsdl:                    @wsdl,
        endpoint:                @endpoint,
        convert_request_keys_to: :none,
        soap_version:            1,
        pretty_print_xml:        true,
        filters:                 [:password],
        logger:                  @soap_logger,
        log_level:               @soap_log_level,
        log:                     @soap_log
      )
    end


    # Private: Login, run session commands specified in block, log out.
    #
    # &block - The block from the constructor is passed here and executed.
    #
    # Returns nothing.
    def login_and_run(&block)
      login
      yield self
      logout
    end


    # Private: Decrypt encrypted password (via Envcrypt).
    #
    # password - encrypted password.
    #
    # Returns decrypted password.
    def decrypt(password)
      crypt = Envcrypt::Envcrypter.new
      crypt.decrypt(password)
    end
  end
end
