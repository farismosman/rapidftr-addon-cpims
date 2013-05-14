require 'tmpdir'
require 'zlib'
require 'writeexcel'
require 'rapidftr_addon_cpims/mapper'

module RapidftrAddonCpims
  class ExportTask < RapidftrAddon::ExportTask

    def self.id
      :cpims
    end

    def export(children)
      children.map do |child|
        add_workbook(child) do
          add_worksheet("Child Details") do
            map_meta "Child", @child.unique_identifier
            map_headers
            map_photo

            map_field "PersonId", @child.unique_identifier
            map_field "FirstName", @child.first_name
            map_field "MiddleName", @child.middle_name
            map_field "LastName", @child.last_name
            map_field "ChildCategoryNIds", @child.protection_status
            map_field "Sex", @child.gender
            map_field "DateOfBirth", @child.date_of_birth
            map_field "OtherName", @child.nick_name
            map_field "NationalityNIds", @child.nationality
            map_field "LanguageNIds", @child.languages
            map_field "EthnicityNId", @child.ethnicity_or_tribe

            map_field "Agency", @child.created_organisation
            map_field "SocialWorker", @child.created_by_full_name
            map_field "DatabaseOperator", @child.created_by
            map_field "DateOfRegistration", @child.date_of_registration
          end

          add_worksheet("Father") do
            map_meta "Father", "father-#{child.unique_identifier}"
            map_headers

            map_field "FirstName", @child.fathers_first_name
            map_field "MiddleName", @child.fathers_middle_name
            map_field "LastName", @child.fathers_last_name
            map_field "IsAlive", @child.is_father_alive
            map_field "DeathDetails", @child.father_death_details
          end

          add_worksheet("Mother") do
            map_meta "Mother", "mother-#{child.unique_identifier}"
            map_headers

            map_field "FirstName", @child.mothers_first_name
            map_field "MiddleName", @child.mothers_middle_name
            map_field "LastName", @child.mothers_last_name
            map_field "IsAlive", @child.is_mother_alive
            map_field "DeathDetails", @child.mother_death_details
          end

          add_worksheet("PrimaryCaregiver") do
            map_meta "PrimaryCaregiver", "care-#{child.unique_identifier}"
            map_headers

            map_field "FirstName", @child.care_arrangments_first_name
            map_field "MiddleName", @child.care_arrangments_middle_name
            map_field "LastName", @child.care_arrangments_last_name
            map_field "RELATIONSHIP", @child.care_arrangements_relationship
            map_field "CurrentAddress", @child.care_arrangements_address
          end

          add_worksheet("Selection_Sheet") do
            add_blobs
          end
        end
      end
    end

    def add_workbook(child_record)
      @child = Mapper.new child_record
      @filename = filename_for @child
      @workbook = WriteExcel.new @filename
      yield
      @workbook.close

      Result.new @filename, File.binread(@filename)
    end

    def add_worksheet(sheet_name)
      @worksheet = @workbook.add_worksheet(sheet_name)
      @row = 0
      yield
    end

    def map_headers
      add_row nil, "CPD - Registration Form"
      add_row "Photo", "PHOTO"
      add_row "PersonId", "", "test"
    end

    def map_meta(model, unique_id)
      @worksheet.write 2, 11, "en"
      @worksheet.write 3, 11, model
      @worksheet.write 4, 11, unique_id
      @worksheet.write 5, 11, "FALSE"
    end

    def map_photo
      if @child.current_photo_key
        @worksheet.insert_image 'N5', @child.photo_data
      end
    end

    def map_field(column, value)
      unless column.nil? || column.empty? || value.nil? || value.empty?
        add_row column, "", value
      end
    end

    def add_row(*values)
      @worksheet.write_row @row, 0, values
      @row = @row + 1
    end

    def add_blobs
      (0..4).each do |i|
        @worksheet.write 0, i, self.class.blobs[i]
      end

      (1..10).each do |i|
        @worksheet.write i, 0, self.class.blobs[i+4]
      end
    end

    def filename_for(record)
      return File.join(self.class.options[:tmp_dir] || Dir.tmpdir, "#{record._id}.xls")
    end

    def self.blobs
      @blobs ||= Zlib::GzipReader.open(blob_dir) { |gz| gz.readlines }
    end

    def self.blob_dir
      File.expand_path(File.join(__FILE__, '..', '..', '..', 'resources', 'programme-blob.gz'))
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
