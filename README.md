# DatabaseCleaner::ActiveRecord::SeededDeletion

This gem provides a `SeededDeletion` strategy for [database_cleaner](https://github.com/DatabaseCleaner/database_cleaner) that deletes all records from tables except those that existed before the strategy was instantiated.

This is particularly useful for tests that need seeded data to be present, such as integration or end-to-end tests that rely on seed data for proper functionality.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'database_cleaner-activerecord-seeded_deletion'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install database_cleaner-activerecord-seeded_deletion
```

## Usage

```ruby
require 'database_cleaner-activerecord-seeded_deletion'

# Configure DatabaseCleaner to use the SeededDeletion strategy
DatabaseCleaner[:active_record].strategy = DatabaseCleaner::ActiveRecord::SeededDeletion.new

# In your test setup
DatabaseCleaner.start  # This captures the current state of the database

# Run your tests which may create new records

# In your test teardown
DatabaseCleaner.clean  # This deletes only the records created after DatabaseCleaner.start was called
```

### With RSpec

```ruby
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:active_record].strategy = DatabaseCleaner::ActiveRecord::SeededDeletion.new
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
```

### With Cypress on Rails

```ruby
# config/initializers/cypress_on_rails.rb
if defined?(CypressOnRails)
  require 'database_cleaner-activerecord-seeded_deletion'
  DatabaseCleaner[:active_record].strategy = DatabaseCleaner::ActiveRecord::SeededDeletion.new
end
```

## How It Works

The `SeededDeletion` strategy:

1. When `start` is called, it captures the maximum ID for each table in the database
2. When `clean` is called, it only deletes records with IDs greater than the captured maximum

This approach preserves all pre-existing data (like seed data) while cleaning up any records created during tests.

## Limitations

- This strategy only works with tables that have an integer `id` column as their primary key
- It assumes that new records will have higher IDs than existing records
- It may not be suitable for tables with non-sequential IDs or custom primary keys

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DatabaseCleaner/database_cleaner-activerecord-seeded_deletion. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

The gem is available as open source under the terms of the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).