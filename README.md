# Civic SIP SDK

[![Build Status](https://travis-ci.com/BinaryStorms/civic-sip-ruby-sdk.svg?branch=master)](https://travis-ci.com/BinaryStorms/civic-sip-ruby-sdk)
[![Coverage Status](https://coveralls.io/repos/github/BinaryStorms/civic-sip-ruby-sdk/badge.svg?branch=master)](https://coveralls.io/github/BinaryStorms/civic-sip-ruby-sdk?branch=master)

Civic [Secure Identity Platform (SIP)](https://www.civic.com/products/secure-identity-platform) API client implemented in Ruby.

## Geting Started

### Dependencies

* [HTTParty](https://github.com/jnunemaker/httparty) for making HTTP requests
* [ruby-jwt](https://github.com/jwt/ruby-jwt) for handling all the JWT encoding/decoding

### Installing

#### Using Rubygems

```
gem install civic_sip_sdk
```

#### Using bundler
Add the following line in your `Gemfile`:

```
gem 'civic_sip_sdk'
```

then run ``` bundle install ```

### Usage

Exchange the JWT token for user data:

```ruby
require 'civic_sip_sdk'

# appId - your Civic application id
# env - your Civic app environment, :dev or :prod (default)
# private key - your Civic private signing key
# secret - your Civic secret
client = CivicSIPSdk.new_client('appId', :env, 'private key', 'secret')
user_data = client.exchange_code(jwt_token: 'your token from Civic frontend JS lib')
```

Access user data items:

```ruby
# Civic userId value
user_id = user_data.user_id
# get a list of all the user data items
data_items = user_data.data_items
# you can access all the attributes in each data item
an_item = data_items.first
label = an_item.label
value = an_item.value
is_valid = an_item.is_valid
is_owner = an_item.is_owner
```

Access user data item by label:

```ruby
an_item = user_data.by_label('contact.personal.email')
label = an_item.label
value = an_item.value
is_valid = an_item.is_valid
is_owner = an_item.is_owner
```

### Running tests

``` bundle exec rspec ```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
