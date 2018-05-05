# WORK IN PROGRESS

**Contributors**: Before submitting a pull request, be sure to read and agree to our [Terms and Conditions](https://s3-us-west-2.amazonaws.com/civic.com/cdp_terms.pdf).

# Civic SIP Plugin - Ruby

Civic [Secure Identity Platform (SIP)](https://www.civic.com/products/secure-identity-platform) API client implemented in Ruby.

**Welcome Bounty Hunters!** Part of your job will be filling out the below. We've included some place holder notes to help with the structure. See [requirements](REQUIREMENTS.md) and [contributing](CONTRIBUTING.md) to get started.

## Geting Started

### Dependencies

* The wonderful JWT gem

### Installing

## Using Rubygems:

```
gem install civic_sip
```

## Using Bundler:

Add the following to your Gemfile:

```
gem 'civic_sip'
```

And run `bundle_install`

### Global Configuration

CivicSIP can be configured globally.

```ruby
CivicSIP.configure do |config|
  config.private_signing_key = 'your private signing key'
  config.secret              = 'your secret'
  config.app_id              = 'your app ID'
end
```

### Usage (with global configuration)

```ruby
CivicSIP.exchange_code('token received from civic.sip.js')

# A successful request returns a hash like this:
#
# {
#   userId: 'user-id',
#   data: [
#     {
#       'label'   => 'contact.personal.email',
#       'value'   => 'foo@example.com',
#       'isValid' => true,
#       'isOwner' => true
#     },
#     ...
#   ]
# }
```

### Usage (without global configuration)

If you don't want to configure CivicSIP globally,
you can pass your app ID, signing key, and secret directly
to the client and exchange your code that way:

```ruby
CivicSIP::Client.new(
  'your app ID',
  'your private signing key',
  'your secret'
).exchange_code('token received from civic.sip.js')
```

### Running tests

The tests are written with rspec and the suite can be run with:

```
rake spec
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.
## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/civic-community/civic-sip-api-ruby/tags).
## Authors

* **Jim Ryan**

See also the list of [contributors](https://github.com/civic-community/civic-sip-api-ruby/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments
