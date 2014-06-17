$LOAD_PATH << '../lib'

require 'rubygems'
require 'bundler/setup'

require 'birst_command'
require 'savon/mock/spec_helper'
require 'session_spec_helper'
require_relative 'bc_spec_fixtures'

include Birst_Command
include Savon::SpecHelper
include SessionSpecHelper
