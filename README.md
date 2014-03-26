Birst_Command
====================

Birst Command is a Ruby gem that allows you to build Ruby scripts that interface
with the Birst Web API.


# Installation & Setup

Install the gem using `gem install Birst_Command` or using rvm or
rbenv/bundler as you prefer.

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

Birst commands are submitted in session blocks, which automatically perform the
process of logging in, tracking the login token, and logging out.  For example,
to list all spaces that you have rights to, you can submit the following code

    Birst_Command::Session.start do |bc|
      spaces = bc.list_spaces
      puts "#{JSON.pretty_generate spaces}"
    end

Which would return something like

    {
      "user_space": [
        {
          "name": "MyGreatSpace",
          "owner": "name@myplace.com",
          "id": "b413207d-3fe2-4309-1b4a-ac8e961daad2"
        },
        {
          "name": "MyOtherGreatSpace",
          "owner": "name@myplace.com",
          "id": "a113207d-3fe2-4310-1b4a-b58e961da123"
        }
      ]
    }

The `spaces` variable is a Ruby hash parsed from the SOAP response.
The structure of the returned hash follows the structure that Birst
returns.


## Helper Methods

I find some of the Birst API responses to be rather cumbersome.  For
example, why do I need hash with a single `user_space` key?  I'd
rather have an array of hashes here.  To that end I find it convenient
to define helper methods that extend the Session class to simplify
some of this.  To override the return value of the native
`list_spaces` command, you can do the following

    class Birst_Command::Session
      def list_spaces(*args)
        result = command __method__, *args
        [result[:user_space]].flatten
      end 
    end

You can then execute the same `list_spaces` command above, but you get
an array of hashes rather than hash with a key that points to an array
of hashes.

I have not included any of these helper methods in the Birst Command
gem because what I find helpful, you may not.  Birst Command just
provides the basic interface.

## Command arguments

Some Birst API commands require arguments.  All arguments are supplied as an argument
hash.  For example, to create a new space,

    Birst_Command::Session.start do |bc|
      new_space_id = bc.create_new_space :spaceName => "myNewSpace",
                                         :comments => "Just testing",
                                         :automatic => "false"
    end

## camelCase/snake_case issues

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

