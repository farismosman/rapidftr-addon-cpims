require 'writeexcel'

module RapidftrAddonCpims
  class ExportTask < RapidftrAddon::ExportTask

    def export(children)
      children.each do |child|
        add_workbook(child) do
          add_worksheet("Child Details") do
            map "FirstName", "First Name", @child.first_name
            map "MiddleName", "Middle Name", @child.middle_name
            map "LastName", "Last Name", @child.last_name
          end
        end
      end
    end

    def self.name
      "CPIMS"
    end

    def add_workbook(child_record)
      @child = Mapper.new child_record
      @filename = format_filename @child
      @workbook = WriteExcel.new @filename
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

    def format_filename(record)
      return "#{record._id}.xls"
    end
  end
end
