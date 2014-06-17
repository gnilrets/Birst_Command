module Birst_Command

  # Public: Configatron instance used to set default options for Birst_Connect
  Settings = Configatron::Store.new

  def self.load_default_settings
    # Default settings applied to all sessions (can be overridden in specific session)
    Settings.session do |session|
      session.wsdl           = "https://app2101.bws.birst.com/CommandWebService.asmx?WSDL"
      session.endpoint       = "https://app2101.bws.birst.com/CommandWebService.asmx"
      session.username       = ENV['BIRST_USER'] || "BIRST_USER"
      session.password       = ENV['BIRST_PWD'] || "BIRST_PWD"
      session.soap_log       = true
      session.soap_log_level = :error
      session.soap_logger    = Logger.new(STDOUT)
    end
  end
  load_default_settings

  def self.load_settings_from_file(file)
    parse_erb = ERB.new(IO.read(file)).result(binding)
    settings = YAML.load(parse_erb).symbolize_keys
    Settings.configure_from_hash(settings)
  end

end
