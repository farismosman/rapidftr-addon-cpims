require 'rspec'
require 'rapidftr_addon'
require 'rapidftr_addon_cpims'
require 'factory_girl'

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.mock_with :rspec
  config.include FactoryGirl::Syntax::Methods

  def build_child(attributes = {})
    RapidftrAddonCpims::Mapper.new attributes_for(:child, attributes)
  end
end
