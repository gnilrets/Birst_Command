Changelog
==============

### v0.6.0
- Config file now uses YAML instead of JSON

- Replaced the `Config` module with a `Settings` constant that uses
  [Configatron](https://github.com/markbates/configatron) to configure
  default settings for all subsequent sessions.

- Remove the `start` method of `Birst_Command::Session`.  Sessions are now
  created using `new`.  All arguments use `Settings` as defaults, but can
  be overridden on a session-by-session basis.

- Renamed `Session#token` to `Session#login_token`.

- Renamed `Session#auth_cookies` to `Session#auth_cookie`.

- Replaced `Session` option `use_cookie` with `auth_cookie`.


### v0.5.0
- Migrated password handling to use Envcrypt
