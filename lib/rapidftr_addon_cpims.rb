module RapidftrAddonCpims
  class Task

    def split_child_name(name)
      full_name = name.split
      names = {:FirstName => full_name.first, :LastName => full_name.last}
      if full_name[1..-2].nil?
        names.merge!(:MiddleName => "")
      else
        names.merge!(:MiddleName => full_name[1..-2].join(" "))
      end
      names
    end
  end
end
