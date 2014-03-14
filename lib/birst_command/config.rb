module Birst_Command
  module BCConfig
    extend self

    attr_accessor :config_full_path
    @config_full_path = File.join(File.dirname(__FILE__),"../../config.json")

  end
end
