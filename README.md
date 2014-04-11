Birst_Command
====================

Birst Command is a Ruby gem that allows you to build Ruby scripts that
interface with the Birst Web API.

Note: this is not an officially-sanctioned Birst project.  I'm just a
Birst user that needed to set up a very basic Ruby interface.

# Installation & Setup

Install the gem using `gem install Birst_Command` or using rvm or
rbenv/bundler as you prefer.

After installing, you'll need to create a Birst Command config file
that contains the credentials you'll use to connect to Birst.  This
config file should look like,

    {
        "wsdl": "https://login.bws.birst.com/CommandWebService.asmx?WSDL",
        "endpoint": "https://login.bws.birst.com/CommandWebService.asmx",
        "username": "name@myplace.com",
        "password": "obfuscated pwd"
    }

Most users should only need to modify the username and password.
Since I have a strong aversion to storing passwords in plaintext, the
password in the config file needs to be an obfuscated password.  Birst
Command comes with a password obfuscator that can be executed via

    $ obfuscate_pwd.rb mypassword
    0x8GOZ5nA3oRSSS8ao1l6Q==

Copy and paste the obfuscated password into the config file and **save
to a secure location**.  If any attacker is able to get your
obfuscated password and knows it was created using this program, it
would be trivial to get your Birst login credentials.

# Usage - Birst command line tool

Birst Command also installs a rudimentary command line tool for interacting
with the Birst web API.  It's still very simple.  If you want more functionality,
please drop me a line in the github repository.

To use the command line tool, put the config file created above in
$HOME/.birstcl.  Then run Birst commands using `birstcl`.  You'll have to refer
to the [Birst Documentation](https://app2102.bws.birst.com/CommandWebService.asmx)
for a full list of commands.  All birst commands should be submitted using snake_case
and arguments using the exact camelCase specified in the Birst documentation.  See
below for an explanation of this bizarre requirement.  Here are some examples:

List spaces

    birstcl -c list_spaces

Get list of sources for a space

    birstcl -c get_sources_list -a '{ spaceID: "383nf0d7-3875-3829-3hff-faba8936180a" }'

Copy space with options

    birstcl -c copy_space -a '{ spFromID: "9ab9865c-37a8-0586-e856-ddd3856a0371", spToID: "3957a9b7-38c1-175v-3985-1957f1836a93", mode: "replicate", options: "data;repository;settings-basic" }'

# Usage - As Ruby library

In your Ruby program, include the Birst Command gem and load the config file via

````ruby
require 'rubygems'
require 'bundler/setup'
require 'Birst_Command'

Birst_Command::Config.read_config(File.join(File.dirname(__FILE__),"config.json"))
````

Birst commands are submitted in session blocks, which automatically
perform the process of logging in, tracking the login token, and
logging out.  For example, to list all spaces that you have rights to,
you can submit the following code

````ruby
Birst_Command::Session.start do |bc|
  spaces = bc.list_spaces
  puts "#{JSON.pretty_generate spaces}"
end
````

Which would return something like

````ruby
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
````

The `spaces` variable is a Ruby hash parsed from the SOAP response.
The structure of the returned hash follows the structure that Birst
returns.


## Helper methods

I find some of the Birst API responses to be rather cumbersome.  For
example, why do I need hash with a single `user_space` key?  I'd
rather have an array of hashes here.  To that end I find it convenient
to define helper methods that extend the Session class to simplify
some of this.  To override the return value of the native
`list_spaces` command, you can do the following

````ruby
class Birst_Command::Session
  def list_spaces(*args)
    result = command __method__, *args
    [result[:user_space]].flatten
  end 
end
````

You can then execute the same `list_spaces` command above, but you get
an array of hashes rather than hash with a key that points to an array
of hashes.

I have not included any of these helper methods in the Birst Command
gem because what I find helpful, you may not.  Birst Command just
provides the basic interface.

## Command arguments

Some Birst API commands require arguments.  All arguments are supplied
as an argument hash.  For example, to create a new space,

````ruby
Birst_Command::Session.start do |bc|
  new_space_id = bc.create_new_space :spaceName => "myNewSpace",
                                     :comments => "Just testing",
                                     :automatic => "false"
end
````

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

