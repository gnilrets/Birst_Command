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

end
