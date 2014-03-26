#!/usr/bin/env ruby
require "birst_command"

if ARGV[0]
  puts Birst_Command::Obfuscate.obfuscate(ARGV[0])
else
  puts "USAGE: ./obfuscate_pwd <plaintxt password>"
end

