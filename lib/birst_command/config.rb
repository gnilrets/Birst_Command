module Birst_Command
  module BCConfig
    extend self

    attr_accessor :config_full_path
    @config_full_path = File.join(File.dirname(__FILE__),"../../config.json")

    attr_accessor :options
    @options = {}

    def read_config
      @options = @options.merge!(JSON.parse(IO.read(@config_full_path), :symbolize_names => true))
    end

  end
end
