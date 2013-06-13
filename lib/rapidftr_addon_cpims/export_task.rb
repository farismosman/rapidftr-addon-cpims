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
            map_meta "Child", @child[:unique_identifier]
            map_headers
            map_photo

            map_field "PersonId", @child[:unique_identifier]
            map_field "Status", @child[:protection_status]
            map_field "UNHCRId", @child[:id_document]
            map_field "ICRCId", @child[:icrc_ref_no]
            map_field "FirstName", @child[:name]
            map_field "LastName", " "
            map_field "ChildCategoryNIds", @child[:protection_status]
            map_field "Sex", @child[:gender]
            map_field "DateOfBirth", @child.parse_date_from(:date_of_birth)
            map_field "OtherName", @child[:nick_name]
            map_field "NationalityNIds", @child[:nationality]
            map_field "LanguageNIds", @child[:languages]
            map_field "EthnicityNId", @child[:ethnicity_or_tribe]

            map_field "Agency", @child[:created_organisation]
            map_field "SocialWorker", @child[:created_by_full_name]
            map_field "DatabaseOperator", @child[:created_by]
            map_field "DateOfRegistration", @child.date_from(:created_at)
          end

          add_worksheet("Father") do
            map_meta "Father", "father-#{child[:unique_identifier]}"
            map_headers

            map_field "FirstName", @child[:fathers_name]
            map_field "LastName", " "
            map_field "IsAlive", @child.alive?(:is_father_alive)
            map_field "DeathDetails", @child[:father_death_details]
          end

          add_worksheet("Mother") do
            map_meta "Mother", "mother-#{child[:unique_identifier]}"
            map_headers

            map_field "FirstName", @child[:mothers_name]
            map_field "LastName", " "
            map_field "IsAlive", @child.alive?(:is_mother_alive)
            map_field "DeathDetails", @child[:mother_death_details]
          end

          add_worksheet("PrimaryCaregiver") do
            map_meta "PrimaryCaregiver", "care-#{child[:unique_identifier]}"
            map_headers

            map_field "FirstName", @child[:caregivers_name]
            map_field "LastName", " "
            map_field "IsAlive", @child.alive?(:is_caregiver_alive)
          end

          add_worksheet("Separated and Unaccompanied") do
            add_row "ea421eb0-b229-4dec-885d-e8fd11fc5347", nil, "Separated and Unaccompanied Children Form"

            map_subsequent_field "d063c4be-903a-47c9-95c1-d5f0c08ea870", @child[:characteristics]
            map_subsequent_field "dbb2b258-7cca-401a-be8d-f2cccdcdc8f6", @child.parse_date_from(:date_of_separation)
            map_subsequent_field "4894026b-862f-4fb8-a543-199ed2361f57", @child[:separation_place]
            map_subsequent_field "1e757f8f-4f8c-45dc-a5d0-01af153bc426", @child[:wishes_wants_contact]
            map_subsequent_field "d0b9521f-406d-4f92-ad67-0192ad64df58", @child[:separation_details]

            map_subsequent_field "64f4c887-2b59-4a59-a845-d8f2b9f2cad5", @child.remove_quotes(:care_arrangements)
            map_subsequent_field "72688c03-be30-4a62-8807-fa56d5468a35", @child[:care_arrangments_name]
            map_subsequent_field "1d939745-3f0e-4739-83fd-07c29355ea11", @child[:care_arrangements_relationship]
            map_subsequent_field "9f0440ff-f2fe-400d-becd-17eaa3b857fa", @child[:care_arrangements_address]

            map_subsequent_field "3416132f-cd1e-485b-98ee-6600055a9de0", @child[:wishes_name_1]
            map_subsequent_field "d026bc18-1743-48fe-8231-eb9b24a461d7", " "
            map_subsequent_field "5959a389-8db3-4313-abcf-773b75bdd8ce", @child[:wishes_address_1]
            map_subsequent_field "da12d65d-f47c-4855-bf18-695fcb6f65d8", @child[:wishes_telephone_1]

            map_subsequent_field "9c99ddea-57e6-43c7-916f-19e9ddfd4cee", @child[:wishes_name_2]
            map_subsequent_field "fd3a9d32-8628-4b9f-a47d-ea88194ac321", " "
            map_subsequent_field "e0f62110-4751-4690-ad17-eaf8dbac42e9", @child[:wishes_address_2]
            map_subsequent_field "934e5728-0fcf-43a8-b3d4-c90bb8cd8cc0", @child[:wishes_telephone_2]

            map_subsequent_field "acb4a436-420e-4eed-a397-4a813507a32a", @child[:wishes_name_3]
            map_subsequent_field "33b8f51d-9473-4b59-9758-4fbe91227435", " "
            map_subsequent_field "c8bd79c0-b14f-4480-8601-a3f8fac4ae57", @child[:wishes_address_3]
            map_subsequent_field "08aef0c7-54b6-4584-bfc7-401b0f760c89", @child[:wishes_telephone_3]
          end

          add_worksheet("Follow up Form") do
            insert_data_from_column 2, "Follow up Form"
            insert_data_from_column 2, "This form records information gathered during follow up visits to a child. Follow up visits may take place before or after reunification with a caregiver. This form can be completed more than once for each child. "
            map_field "AgencyNid", "Sender Agency"
            map_field "SocialWorkerNid", "Social Worker"
            map_field "UserNid", "Database Operator"
            map_field "AreaNid", "Area Name"
            map_field "DateApplied", "Date"

            insert_data_from_column 2, "Outcome of Follow-Up Visit"
            insert_data_from_column 2, "1. Was the child seen during the visit? *"
            insert_data_from_column 2, @child[:was_child_seen]
            insert_data_from_column 2, "2. If not why not?"
            insert_data_from_column 2, @child[:reason_why]

            insert_data_from_column 2, "Current Care Arrangements"
            insert_data_from_column 2, "3. Is the child still living with the same caregiver?"
            insert_data_from_column 2, @child[:child_living_with_same_caregiver]
            insert_data_from_column 2, "4. If not give reasons for change"
            insert_data_from_column 2, @child[:reasons_for_change]
            insert_data_from_column 2, "5. If not, give the type of current care arrangements?"
            insert_data_from_column 2, @child[:type_of_current_arrangements]
            insert_data_from_column 2, "6. If not give first name of the caregiver"
            insert_data_from_column 2, @child[:first_name_of_caregiver]
            insert_data_from_column 2, "7. Middle name of the caregiver"
            insert_data_from_column 2, @child[:middle_name_of_caregiver]
            insert_data_from_column 2, "8. Last name of the caregiver"
            insert_data_from_column 2, @child[:last_name_of_caregiver]
            insert_data_from_column 2, "9. If not give Location of new caregiver"
            insert_data_from_column 2, @child[:location_of_new_caregiver]
            insert_data_from_column 2, "10. Address of caregiver"
            insert_data_from_column 2, @child[:address_of_caregiver]
            insert_data_from_column 2, "11. Telephone contact of caregiver"
            insert_data_from_column 2, @child[:telephone_contact_of_caregiver]
            insert_data_from_column 2, "12. Relationship of new caregiver to child"
            insert_data_from_column 2, @child[:relationship_of_caregiver_to_child]
            insert_data_from_column 2, "13. Date new care arrangement started"
            insert_data_from_column 2, @child[:date_new_arrangement_started]
            
            insert_data_from_column 2, "Activities"
            insert_data_from_column 2, "14. Is the child in school or training"
            insert_data_from_column 2, @child[:is_child_in_school_or_training]
            insert_data_from_column 2, "15. Name of School"
            insert_data_from_column 2, @child[:name_of_school]
            insert_data_from_column 2, "16. If not why not?"
            insert_data_from_column 2, @child[:why_not_in_school]
            insert_data_from_column 2, "17. If yes, what type of education?"
            insert_data_from_column 2, @child[:what_type_of_education]
            insert_data_from_column 2, "18. If relevant, what level have they achieved"
            insert_data_from_column 2, @child[:what_have_they_achieved]
            insert_data_from_column 2, "19. What other activities is the child involved in"
            insert_data_from_column 2, @child[:other_activities_child_involved_in]
            insert_data_from_column 2, "20. Start date of training"
            insert_data_from_column 2, @child[:start_date_of_training]
            insert_data_from_column 2, "21. Duration of training"
            insert_data_from_column 2, @child[:duration_of_training]

            insert_data_from_column 2, "Care Assessment"
            insert_data_from_column 2, "22. Personal Assessment?"
            insert_data_from_column 2, @child[:personal_assessment]
            insert_data_from_column 2, "23. Family Assessment?"
            insert_data_from_column 2, @child[:family_assessment]
            insert_data_from_column 2, "24. Community Assessment?"
            insert_data_from_column 2, @child[:community_assessment]
            insert_data_from_column 2, "25. Education Assessment?"
            insert_data_from_column 2, @child[:education_assessment]
            insert_data_from_column 2, "26. Health and Nutrition Assessment?"
            insert_data_from_column 2, @child[:health_and_nutrition_assessment]
            insert_data_from_column 2, "27. Economical Assessment?"
            insert_data_from_column 2, @child[:economical_assessment]

            insert_data_from_column 2, "Further Action"
            insert_data_from_column 2, "28. Is there a need for further follow-up visit(s)?"
            insert_data_from_column 2, @child[:any_need_for_follow_up_visit]
            insert_data_from_column 2, "29. If yes, when do you recommend the next visit to take place?"
            insert_data_from_column 2, @child[:when_follow_up_visit_should_happen]
            insert_data_from_column 2, "30. If not, do you recommend that the case be closed?"
            insert_data_from_column 2, @child[:recommend_that_the_case_be_closed]
            insert_data_from_column 2, "31. Comments"
            insert_data_from_column 2, @child[:any_comments]

            insert_data_from_column 2, "Additional Family Details"
            insert_data_from_column 2, "32. Size of family"
            insert_data_from_column 2, @child[:size_of_family]
            insert_data_from_column 2, "31. Type of Follow-Up"
            insert_data_from_column 2, @child[:type_of_follow_up]
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
    end

    def map_meta(model, unique_id)
      @worksheet.write 2, 11, "en"
      @worksheet.write 3, 11, model
      @worksheet.write 4, 11, unique_id
      @worksheet.write 5, 11, "FALSE"
    end

    def map_photo
      if @child[:current_photo_key]
        @worksheet.insert_image 'N5', @child.photo_data
      end
    end

    def map_field(column, value)
      unless column.nil? || column.empty? || value.nil? || value.empty?
        add_row column, "", value
      end
    end

    def map_subsequent_field(column, value)
      unless column.nil? || column.empty? || value.nil? || value.empty?
        add_row column
        add_row "", "", value
      end
    end

    def add_row(*values)
      insert_data_from_column(0, *values)
    end

    def insert_data_from_column(column_number, *values)
      @worksheet.write_row @row, column_number, values.flatten
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
      return File.join(self.class.options[:tmp_dir] || Dir.tmpdir, "#{record[:unique_identifier]}.xls")
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
