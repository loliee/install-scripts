# install-ruby

[![Build Status](https://travis-ci.org/loliee/install-scripts.svg?branch=master)](https://travis-ci.org/loliee/install-scripts)

Install [install-ruby](https://github.com/coreos/install-ruby), [chruby](https://github.com/postmodern/chruby) and 
finally [ruby](https://www.ruby-lang.org/en/).

## Dependencies

- `curl`
- `build-essential`

## Variables

name             | default   | description
-----------------|-----------|----------------------------------
`CUSER` | `root` | username where rubies will be installed.
`CHRUBY_VERSION` | `0.3.9` | chruby version.
`GEM_LIST`       | `empty`  | list of gem to install sperated by a coma.
`RUBY_VERSION` | `2.3.1` | ruby version.
`INSTALL_RUBY_VERSION` | `0.6.0` | ruby-install version.

## License

MIT © [Maxime Loliée](https://github.com/loliee/)
