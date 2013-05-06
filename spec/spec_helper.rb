require 'rspec'
require 'lib/rapidftr_addon_cpims'
require 'factory_girl'

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.mock_with :rspec
  config.include FactoryGirl::Syntax::Methods
end