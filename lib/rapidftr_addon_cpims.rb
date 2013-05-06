require 'writeexcel'

module RapidftrAddonCpims
  class Task

    attr_accessor :row

    def format_filename(record)
       return "#{record[:id]}.xls"
    end

    def map_to_excel(cpims_db_name, cpims_view_name, value = nil)
      @worksheet.write_row(@row, 0, [cpims_db_name, cpims_view_name, value])
      @row =+ 1
    end

    def workbook(filename, record)
      @record = record
      @workbook = WriteExcel.new(filename)
      yield
      @workbook.close
    end

    def worksheet(sheet_name)
      @worksheet = @workbook.add_worksheet(sheet_name)
      @row = 0
      yield
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
  end
end
