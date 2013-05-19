require 'active_support/core_ext/hash/keys'
require 'chronic'

module RapidftrAddonCpims
  class Mapper
    attr_accessor :child

    def initialize(child)
      @child = (child || {}).stringify_keys!
    end

    def [](property)
      @child[property.to_s]
    end

    def parse_date_from(property)
      begin
        dob_or_age = self[property]
        dob = Chronic.parse(dob_or_age)
        dob ||= Chronic.parse(dob_or_age + " ago")
        dob ? dob.strftime("%m-%d-%Y") : nil
      rescue
        nil
      end
    end

    def date_from(property)
      Date.parse(self[property]).strftime("%m-%d-%Y") rescue nil
    end

    def first_name_from(property)
      self[property][/^[^ ]+/].strip rescue nil
    end

    def last_name_from(property)
      self[property][/[^ ]+$/].strip rescue nil
    end

    def middle_name_from(property)
      self[property][/ .+ /].strip rescue nil
    end

    def photo_data
      StringIO.new(@child.read_attachment(self[:current_photo_key])) if self[:current_photo_key]
    end
  end
end
