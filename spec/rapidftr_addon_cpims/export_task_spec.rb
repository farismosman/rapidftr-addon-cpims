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
    record = double(:_id => "b2dfc87")

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
    @task.row = 0
    @task.worksheet = @worksheet
    @worksheet.should_receive(:write_row).with(0, 0, [nil, nil, nil])

    @task.map(nil, nil, nil)
    @task.row.should == 1
  end
end