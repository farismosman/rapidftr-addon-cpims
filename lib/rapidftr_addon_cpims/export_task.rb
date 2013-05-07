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
      return "#{record._id}.xls"
    end

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
end
