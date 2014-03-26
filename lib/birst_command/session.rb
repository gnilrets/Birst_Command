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
        filters: [:password],
        log_level: @options[:soap_log_level],
        log: @options[:soap_log]
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
      session.execute_block(&b)
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
