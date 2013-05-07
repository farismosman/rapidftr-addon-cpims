module RapidftrAddonCpims
  class Mapper
    attr_accessor :child

    def initialize(child)
      @child = child
    end

    def present?(attribute)
      self.send(attribute) != nil rescue false
    end

    def first_name
      name[/^[^ ]+/].strip if present? "name"
    end

    def last_name
      name[/[^ ]+$/].strip if present? "name"
    end

    def middle_name
      name[/ .+ /].strip if present? "name"
    end

    def method_missing(method, *args)
      @child[method.to_s]
    end
  end
end