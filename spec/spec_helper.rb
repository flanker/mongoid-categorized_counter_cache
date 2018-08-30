require 'bundler/setup'
require 'mongoid'
require 'mongoid/categorized_counter_cache'

MODELS = File.join(File.dirname(__FILE__), 'app/models')
$LOAD_PATH.unshift(MODELS)

require 'rspec'
require 'byebug'

HOST = '127.0.0.1'
PORT = '27117'

Mongoid.configure do |config|
  config.load_configuration({
    clients: {
      default: {
        database: 'mccc_test',
        hosts: [ "#{HOST}:#{PORT}" ]
      }
    },
    options: {
      belongs_to_required_by_default: false
    }
  })
end

Dir[ File.join(MODELS, '*.rb') ].sort.each do |file|
  name = File.basename(file, '.rb')
  autoload name.camelize.to_sym, name
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
