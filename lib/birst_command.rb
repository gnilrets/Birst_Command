$LOAD_PATH << File.dirname(__FILE__)

require 'rubygems'
require 'bundler/setup'

require 'savon'
require 'httpclient'
require 'openssl'
require 'base64'
require 'json'

require 'birst_command/config'
require 'birst_command/obfuscate'
require 'birst_command/session'

include Birst_Command
