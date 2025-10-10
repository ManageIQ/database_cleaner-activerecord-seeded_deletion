require_relative "lib/database_cleaner/active_record/seeded_deletion/version"

Gem::Specification.new do |spec|
  spec.name          = "database_cleaner-activerecord-seeded_deletion"
  spec.version       = DatabaseCleaner::ActiveRecord::SeededDeletion::VERSION
  spec.authors       = ["ManageIQ Team"]
  spec.email         = ["contact@manageiq.org"]

  spec.summary       = "Seeded deletion strategy for database_cleaner-activerecord"
  spec.description   = "A database_cleaner strategy that deletes all records from tables except those that existed before it was instantiated"
  spec.homepage      = "https://github.com/DatabaseCleaner/database_cleaner-activerecord-seeded_deletion"
  spec.license       = "Apache-2.0"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob("{lib/**/*,LICENSE.txt,README.md}")
  spec.require_paths = ["lib"]

  spec.add_dependency "database_cleaner-active_record", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
