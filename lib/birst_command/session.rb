module Birst_Command
  class Session
    def initialize
      Birst_Command::Config.read_config
      puts "Birst_Command::Config.options = #{Birst_Command::Config.options}"
      puts "Birst_Command::Config.options = #{Birst_Command::Config.options}"

      @options = Birst_Command::Config.options
      puts "<Session>@options = #{@options}"
      puts "<Session>@options[:wsdl] = #{@options[:wsdl]}"
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

      if block_given?
        self.instance_eval(&b)
      end
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
          token: "#{@token}"
        })
    end


    def command(&b)
      self.instance_eval(&b)
    end
  end
end
