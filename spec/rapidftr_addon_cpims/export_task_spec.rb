require 'spec_helper'

module RapidftrAddonCpims
  describe ExportTask do

    class ExportTask
      attr_accessor :row
      attr_accessor :child
      attr_accessor :worksheet
      attr_accessor :workbook
    end

    before(:each) do
      @task = ExportTask.new
      @worksheet = WriteExcel.new "temp"
      @workbook = @worksheet.add_worksheet "temp"
    end

    it 'should be an ExportTask addon' do
      RapidftrAddon::ExportTask.all.should include ExportTask
    end

    it 'should have proper id' do
      ExportTask.id.should == :cpims
    end

    it 'should format file name' do
      filename = @task.filename_for build_child :_id => "b2dfc87"
      File.basename(filename).should == "b2dfc87.xls"
    end

    it 'should save under temp dir' do
      ExportTask.stub! :options => { :tmp_dir => 'test1/test2' }
      filename = @task.filename_for build_child
      File.dirname(filename).should == 'test1/test2'
    end

    it 'should open a new workbook' do
      @task.stub! :filename_for => 'temp.xls'
      File.stub! :binread => nil

      WriteExcel.should_receive(:new).with('temp.xls').ordered.and_return(@workbook)
      @workbook.should_receive(:voila_yielded).ordered
      @workbook.should_receive(:close).ordered

      @task.add_workbook(nil) do
        @workbook.voila_yielded
      end
    end

    it 'add_workbook should return proper result' do
      @task.stub! :filename_for => 'temp.xls'
      File.stub!(:binread).with('temp.xls').and_return('dummy data')

      result = @task.add_workbook(nil) { }
      result.data.should == 'dummy data'
      result.filename.should == 'temp.xls'
    end

    it 'export should return array of results' do
      @task.should_receive(:add_workbook).with(1).ordered.and_return('one')
      @task.should_receive(:add_workbook).with(2).ordered.and_return('two')
      @task.should_receive(:add_workbook).with(3).ordered.and_return('three')

      @task.export([1, 2, 3]).should == [ 'one', 'two', 'three' ]
    end

    it 'should create a new worksheet inside the workbook' do
      @task.workbook = @workbook
      @workbook.should_receive(:add_worksheet).with("test").and_return(@worksheet)
      @worksheet.should_receive(:voila_yielded)

      @task.add_worksheet("test") do
        @worksheet.voila_yielded
      end
    end

    it 'should add 1 to row after writing to excel ' do
      @task.row, @task.worksheet = 5, @worksheet
      @worksheet.should_receive(:write_row).with(5, 0, ["a", "b", "c"])

      @task.map "a", "b", "c"
      @task.row.should == 6
    end

    it 'should skip the row if any parameter is nil or empty' do
      @task.row, @task.worksheet = 3, @worksheet
      @worksheet.should_not_receive(:write_row)

      @task.map "a", "b", ""
      @task.map "a", "b", nil
      @task.map "a", "", "c"
      @task.map "a", nil, "c"
      @task.map "", "b", "c"
      @task.map nil, "b", "c"

      @task.row.should == 3
    end

    it 'should export photo' do
      child = build_child :current_photo_key => "test"
      child.stub! :photo_data => "test"

      @task.worksheet, @task.child = @worksheet, child
      @worksheet.should_receive(:insert_image).with('N5', "test").and_return(true)

      @task.map_photo
    end

    it 'should not export photo' do
      child = build_child
      @task.worksheet, @task.child = @worksheet, child
      @worksheet.should_not_receive(:insert_image)
      @task.map_photo
    end

    it 'should translate' do
      I18n.t("addons.export_task.cpims.name").should == "Export to CPIMS Addon"
    end
  end
end
