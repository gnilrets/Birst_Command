#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__),"..","lib","birst_command")

begin
  puts Obfuscate.obfuscate(ARGV[0])
rescue
  puts "USAGE: ./obfuscate_pwd <plaintxt password>"
end

