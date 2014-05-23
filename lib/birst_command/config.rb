module Birst_Command
  require 'erb'
  module Config
    extend self

    attr_accessor :config_full_path
    @config_full_path = File.join(File.dirname(__FILE__),"../../config.json")

    attr_accessor :options
    @options = {
      :soap_log_level => :error,
      :soap_log => false
    }

    def read_config(config_full_path = @config_full_path)
      parse_erb = ERB.new(IO.read(config_full_path)).result(binding)
      parse_json = JSON.parse(parse_erb, :symbolize_names => true)
      @options = @options.merge!(parse_json)
    end
    
    def set_debug
      @options = @options.merge!({
                                  :soap_log_level => :debug,
                                  :soap_log => true
                                })
    end
  end
end
