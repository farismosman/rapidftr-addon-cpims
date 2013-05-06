require 'writeexcel'

module RapidftrAddonCpims
  class Task

    def add_workbook(child_record)
      @child = child_record
      @workbook = WriteExcel.new(format_filename(@child))
      yield
      @workbook.close
    end

    def add_worksheet(sheet_name)
      @worksheet = @workbook.add_worksheet(sheet_name)
      @row = 0
      yield
    end

    def map(cpims_db_name, cpims_view_name, value = nil)
      @worksheet.write_row(@row, 0, [cpims_db_name, cpims_view_name, value])
      @row =+ 1
    end

    def split_name(name)
      full_name = name.split
      names = {:FirstName => full_name.first, :LastName => full_name.last}
      if full_name[1..-2].nil?
        names.merge!(:MiddleName => "")
      else
        names.merge!(:MiddleName => full_name[1..-2].join(" "))
      end
      names
    end

    def format_filename(record)
      return "#{record[:id]}.xls"
    end
  end
end
