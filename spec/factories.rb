require 'factory_girl'

FactoryGirl.define do

  factory :child, :class => Hash do
    ignore do
      sequence :counter, 1000000
    end

    _id { "child-id-#{counter.to_s}"}
    unique_identifier { "unique-id-#{counter.to_s}" }
    short_id { counter.to_s }
    name { "Child #{counter.to_s}" }
  end

end