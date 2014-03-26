Birst_Command
====================

Birst Command is a Ruby gem that allows you to build Ruby scripts that interface
with the Birst Web API.


# Installation & Setup

Install the gem using `gem install Birst_Command` or using rvm or rbenv as you prefer.

After installing, you'll need to create a Birst Command config file that contains
the credentials you'll use to connect to Birst.  This config file should look like,

    {
        "wsdl": "https://login.bws.birst.com/CommandWebService.asmx?WSDL",
        "endpoint": "https://login.bws.birst.com/CommandWebService.asmx",
        "username": "name@myplace.com",
        "password": "obfuscated pwd"
    }

Most users should only need to modify the username and password.  Since I have a strong
aversion to storing passwords in plaintext, the password in the config file needs to
be an obfuscated password.  Birst Command comes with a password obfuscator that can be
executed via

    $ obfuscate_pwd.rb mypassword
    0x8GOZ5nA3oRSSS8ao1l6Q==

Copy and paste the obfuscated password into the config file and **save
to a secure location**.  If any attacker is able to get your
obfuscated password and knows it was created using this program, it
would be trivial to get your Birst login credentials.


# Usage

In your Ruby program, include the Birst Command gem and load the config file via

    require 'rubygems'
    require 'bundler/setup'
    require 'Birst_Command'

    Birst_Command::Config.read_config(File.join(File.dirname(__FILE__),"config.json"))

Birst commands are submitted in 


### camelCase/snake_case issues

Birst Command uses [Savon](http://savonrb.com/version2/client.html) as
the underlying framework used to communicate with the Birst SOAP API.
Savon expects commands in snake_case format and converts them into
camelCase when submitted to the Birst API (e.g., `list_spaces` is
converted to `listSpaces`).  This behavior is *not* configurable.
Savon also has options for converting the arguments of parameters from
snake_case into camelCase.  Unfortunately, the Birst Web API is not
entirely consistent in its use of camelCase for arguments (e.g.,
`spaceId` is used in `deleteSpace` but `spaceID` is used in
`listUsersInSpace`).  This inconsistency requires us to **submit
commands as snake_case and arguments as the camelCase that Birst
uses.**


ToDo:

* Basic usage examples (take from test)
* Helper functions
