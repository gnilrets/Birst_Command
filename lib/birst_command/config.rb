module Birst_Command
  module Config
    extend self

    attr_accessor :config_full_path
    @config_full_path = File.join(File.dirname(__FILE__),"../../config.json")

    attr_accessor :options
    @options = {}

    def read_config(config_full_path = @config_full_path)
      @options = @options.merge!(JSON.parse(IO.read(config_full_path), :symbolize_names => true))
    end

  end
end
