Birst_Command
====================
[![Gem Version](https://badge.fury.io/rb/Birst_Command.svg)](http://badge.fury.io/rb/Birst_Command)

Birst Command is a Ruby gem that allows you to build Ruby scripts that
interface with the Birst Web API.  It also comes with a simple command line
tool that can be used to execute simple API requests from the command line.

Note: this is not an officially-sanctioned Birst project.  I'm just a
Birst user that needed to set up a very basic Ruby interface.

# Installation & Setup

**SPECIAL NOTE:** Many changes since version 0.5.0.  Read the
  [Changelog](CHANGELOG.md).

Prerequisites: Ruby > 2.0 and rubygems.

Install the gem using `gem install Birst_Command` or using rvm or
rbenv/bundler as you prefer.

After installing, you'll need to create a Birst Command config file
that contains the credentials you'll use to connect to Birst.  This
is a yaml file that should look something like

````yaml
---
session:
  wsdl: "https://app2101.bws.birst.com/CommandWebService.asmx?WSDL"
  endpoint: "https://app2101.bws.birst.com/CommandWebService.asmx"
  username: "BirstUsername"
  password: "EncryptedPassword"
  soap_log: true
  soap_log_level: :debug
````
Save it to `$HOME/.birstcl`.  Most users should only need to modify
the username and password. (**Note**: do not use `login.bws.birst.com`
since it does not use an updated WSDL; a specific app server must be
specified).  Since I have a strong aversion to storing passwords in
plaintext, the password in the config file needs to use and encrypted
password.  Birst Command comes bundled with a password encryptor
called [Envcrypt](https://github.com/gnilrets/envcrypt) that can be
executed via

````bash
$ envcrypt -s mypassword
````

which should give an output similar to
````
Encrypted Secret: 2KwUMeJIqsjPWWF9Fw0I+w==
ENVCRYPT_KEY='V/V919RKnz8l2M002336bg==$ARoQfp/9pfv5kVN/ysRuStLuTWJFZhQF1f49xkHbcwQ=$YAjVhHOXlcagmZoFYgPWdQ=='
WARNING: It is critical that the key and encryption password be stored separately!
````

Copy and paste the encrypted password (aka "secret') into the
`$HOME/.birstcl` config file.  You will also need to ensure that the
`ENVCRYPT_KEY` environment variable is set as indicated above.  If you're
running in a development environment, you can include these in your
bash `~/.profile` file.

Also note that the YAML config file is pre-processed with ERB.  So if
you also want to keep your encrypted password in an environment
variable, you could replace the `password` line above with
````yaml
  ...
  password: "<%= ENV['MY_ENCRYPTED_PASSWORD'] %>"
  ...
````

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

## Cookies

Many Birst web API commands return a job token that can be used to check up
on the status of a job as it progresses.  The job tokens are tied to a specific
server, and the only way to direct your login to a specific server is to use
cookies.  So, if you wanted to copy a space with one command and then
check whether the job is complete with another, you need to do something
like the following.

Copy a space and write a cookie file

    birstcl -c copy_space -a '{ spFromID: "f9cb64fe-58a1-1db6-a7a8-9f091b4ea96f", spToID: "12913e53-3eac-4f98-91ab-2fqf345e22e5", mode: "replicate", options: "data;datastore;repository;useunloadfeature" }' -w ./cookie

Note the job token returned as result and then run another command to
check whether the job is complete by reading the cookie file

    birstcl -c is_job_complete -a '{ jobToken: "9f636262f4c73d7503bf240ea08de040" }' -r ./cookie

# Usage - As Ruby library

In your Ruby program, include the Birst Command gem and load the config file via

````ruby
require 'rubygems'
require 'bundler/setup'
require 'birst_command'

Birst_Command.load_settings_from_file(file)

# Or you can forego the settings file and set them explicitly in code via
Birst_Command::Settings.session.username = "George"

````

Birst commands are submitted in session blocks, which automatically
perform the process of logging in, tracking the login token, and
logging out.  For example, to list all spaces that you have rights to,
you can submit the following code

````ruby
Birst_Command::Session.new do |bc|
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

## Command arguments

Some Birst API commands require arguments.  All arguments are supplied
as an argument hash.  All arguments are mandatory even if they're blank/null
(Birst web API requirement).  For example, to create a new space,

````ruby
Birst_Command::Session.new do |bc|
  new_space_id = bc.create_new_space :spaceName => "myNewSpace", :comments => "Just testing",:automatic => "false"
end
````

## Cookies

The start session block can also accept an argument named `use_cookie` to
pass a cookie to be used during startup.  For example, suppose we start
a copy job and save the `session_cookie` and `job_token` in variables.

````ruby
session_cookie = nil
job_token = nil
Bist_Command::Session.new do |bc|
  job_token = bc.copy_space :spFromID => @from_id, :spToID => @to_id, :mode => "replicate", :options => "data;datastore;useunloadfeature"
  session_cookie = bc.auth_cookie
end
````
In a subsequent session we can use the `session_cookie` on login via

````ruby
is_job_complete = false
Birst_Command::Session.new auth_cookie: session_cookie do |bc|
  is_job_complete = bc.is_job_complete :jobToken => job_token
end
puts "COMPLETE? #{is_job_complete}"
````

## Helper methods

I find some of the Birst API responses to be rather cumbersome.  For
example, why do I need hash with a single `user_space` key when I
run the `list_spaces` command?  I'd
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
