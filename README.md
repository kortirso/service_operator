# ServiceOperator
Simple interactor is a gem based on ideas of gems [interactor](https://github.com/collectiveidea/interactor) and [dry-transaction](https://github.com/dry-rb/dry-transaction). ServiceOperator provides a simple way to processing over many steps and by many different objects.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'service_operator'
```

And then execute:
```bash
$ bundle install
```

## Usage

### Initializer

Add configuration to config/initializers/service_operator.rb:
```ruby
ServiceOperator.configure do |config|
  config.call_parameters_method_name = :call_parameters
end
```

### ApplicationOperator

You can create ApplicationOperator - basis class for your operators
```ruby
class ApplicationOperator
  include ServiceOperator::Helpers

  private

  # this around action is useful when you need to wrap your steps inside transaction
  def use_transaction(operator)
    ActiveRecord::Base.transaction do
      operator.call
    end
  end
end
```

And then you can start creating operators for wrapping services with business logic
```ruby
module Weeks
  class RefreshOperator < ApplicationOperator
    # validating provided parameters for operator
    required_context :week

    # definition for around hooks
    around :use_transaction

    # definition for before hooks
    before :turn_off

    # definition for main steps
    step :finish_week, service: Weeks::FinishService, week: :previous_week
    step :start_week, service: Weeks::StartService
    step :prepare_week, service: Weeks::ComingService

    # definition for after hooks
    after :turn_on

    private

    def turn_off; end

    def turn_on; end

    def previous_week
      context.week.previous
    end
  end
end
```

And run your operator
```ruby
  Weeks::RefreshOperator.call(week: week)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kortirso/service_operator.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
