require 'writeexcel'
require 'rapidftr_addon_cpims/mapper'

module RapidftrAddonCpims
  class ExportTask < RapidftrAddon::ExportMultiTask

    def export(children)
      children.each do |child|
        add_workbook(child) do
          add_worksheet("Child Details") do
            map_headers
            map_meta
            map_photo

            map "FirstName", "First Name", @child.first_name
            map "MiddleName", "Middle Name", @child.middle_name
            map "LastName", "Last Name", @child.last_name
            map "ChildCategoryNIds", "Protection concerns", @child.protection_status
            map "Sex", "Sex", @child.gender
            map "OtherName", "Other Name", @child.nick_name
            map "NationalityNIds", "Nationality", @child.nationality
            map "LanguageNIds", "Language", @child.languages
            map "EthnicityNId", "Ethnicity", @child.ethnicity_or_tribe
          end

          add_worksheet("Father") do
            map_headers

            map "FirstName", "First Name", @child.fathers_first_name
            map "MiddleName", "Middle Name", @child.fathers_middle_name
            map "LastName", "Last Name", @child.fathers_last_name
            map "IsAlive", "Is Father Alive", @child.is_father_alive
            map "DeathDetails", "Death Details", @child.father_death_details
          end

          add_worksheet("Mother") do
            map_headers

            map "FirstName", "First Name", @child.mothers_first_name
            map "MiddleName", "Middle Name", @child.mothers_middle_name
            map "LastName", "Last Name", @child.mothers_last_name
            map "IsAlive", "Is Father Alive", @child.is_mother_alive
            map "DeathDetails", "Death Details", @child.mother_death_details
          end

          add_worksheet("PrimaryCaregiver") do
            map_headers

            map "FirstName", "First Name", @child.care_arrangments_first_name
            map "MiddleName", "Middle Name", @child.care_arrangments_middle_name
            map "LastName", "Last Name", @child.care_arrangments_last_name
            map "RELATIONSHIP", "Relationship", @child.care_arrangements_relationship
            map "CurrentAddress", "Current Address", @child.care_arrangements_address
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

    def map(cpims_db, cpims_view, value)
      unless cpims_db.nil? or cpims_db.empty? or cpims_view.nil? or cpims_view.empty? or value.nil? or value.empty?
        add_row cpims_db, cpims_view, value
      end
    end

    def map_headers
      add_row nil, "CPD - Registration Form"
      add_row "Photo", "PHOTO"
    end

    def map_meta
      @worksheet.write 3, 11, "Child"
      @worksheet.write 4, 11, @child.unique_identifier
      @worksheet.write 5, 11, "FALSE"
    end

    def map_photo
      if @child.current_photo_key
        @worksheet.insert_image 'N5', @child.photo_data
      end
    end

    def add_row(*values)
      @worksheet.write_row @row, 0, values
      @row = @row + 1
    end

    def format_filename(record)
      return "#{record._id}.xls"
    end
  end
end

# Patch import method in WriteExcel to handle in-memory images
module Writeexcel
  class Image
    def import
      if @filename.respond_to?(:read)
        @data = @filename.read
      else
        File.open(@filename, "rb") do |fh|
          raise "Couldn't import #{@filename}: #{$!}" unless fh
          @data = fh.read
        end
      end

      @size = data.bytesize
      @checksum1 = image_checksum(@data)
      @checksum2 = @checksum1
      process
    end
  end

  class Worksheet
    def insert_image(*args)
      # Check for a cell reference in A1 notation and substitute row and column
      args = row_col_notation(args)
      # args = [row, col, filename, x_offset, y_offset, scale_x, scale_y]
      image = Image.new(self, *args)
      raise "Insufficient arguments in insert_image()" unless args.size >= 3

      @images << image
    end
  end
end
