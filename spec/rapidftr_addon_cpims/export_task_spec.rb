require 'spec_helper'

describe RapidftrAddonCpims::ExportTask do

  class RapidftrAddonCpims::ExportTask
    attr_accessor :row
    attr_accessor :child
    attr_accessor :worksheet
    attr_accessor :workbook
  end

  before(:each) do
    @task = RapidftrAddonCpims::ExportTask.new
    @worksheet = WriteExcel.new "temp"
    @workbook = @worksheet.add_worksheet "temp"
  end

  it 'should be an ExportTask addon' do
    RapidftrAddon::ExportMultiTask.implementations.should include RapidftrAddonCpims::ExportTask
  end

  it 'should format file name' do
    record = build_child :_id => "b2dfc87"
    filename = @task.format_filename(record)
    filename.should == "b2dfc87.xls"
  end

  it 'should open a new workbook' do
    @task.stub! :format_filename => 'temp.xls'
    WriteExcel.should_receive(:new).with('temp.xls').ordered.and_return(@workbook)
    @workbook.should_receive(:voila_yielded).ordered
    @workbook.should_receive(:close).ordered

    @task.add_workbook(nil) do
      @workbook.voila_yielded
    end
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
end
