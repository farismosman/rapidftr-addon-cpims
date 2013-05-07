require 'active_support/core_ext/hash/keys'

module RapidftrAddonCpims
  class Mapper
    attr_accessor :child

    def initialize(child)
      @child = (child || {}).stringify_keys!
    end

    def present?(attribute)
      self.send(attribute) != nil rescue false
    end

    def first_name
      first_name_from name
    end

    def last_name
      last_name_from name
    end

    def middle_name
      middle_name_from name
    end

    def fathers_first_name
      first_name_from fathers_name
    end

    def fathers_last_name
      last_name_from fathers_name
    end

    def fathers_middle_name
      middle_name_from fathers_name
    end

    def mothers_first_name
      first_name_from mothers_name
    end

    def mothers_last_name
      last_name_from mothers_name
    end

    def mothers_middle_name
      middle_name_from mothers_name
    end

    def care_arrangments_first_name
      first_name_from care_arrangments_name
    end

    def care_arrangments_last_name
      last_name_from care_arrangments_name
    end

    def care_arrangments_middle_name
      middle_name_from care_arrangments_name
    end

    def photo_data
      StringIO.new(@child.read_attachment(current_photo_key)) if current_photo_key
    end

    def method_missing(method, *args)
      @child[method.to_s]
    end

    private

    def first_name_from(full_name)
      full_name[/^[^ ]+/].strip rescue nil
    end

    def last_name_from(full_name)
      full_name[/[^ ]+$/].strip rescue nil
    end

    def middle_name_from(full_name)
      full_name[/ .+ /].strip rescue nil
    end
  end
end
