require 'rspec'
require 'rapidftr_addon'
require 'rapidftr_addon_cpims'
require 'lib/rapidftr_addon_cpims/mapper'
require 'factory_girl'

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.mock_with :rspec
  config.include FactoryGirl::Syntax::Methods
end