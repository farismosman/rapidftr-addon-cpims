require 'spec_helper'

describe RapidftrAddonCpims::Task do

  before(:each) do
    @task = RapidftrAddonCpims::Task.new
  end

  it 'should split child name to first name and last name' do
    child_name = "Some Random Name"

    names = @task.split_name(child_name)

    names[:FirstName].should == 'Some'
    names[:LastName].should == 'Name'
  end

  it 'should return empty string when middle name does not exist' do
    child_name = "First Last"

    names = @task.split_name(child_name)

    names[:MiddleName].should == ""
  end

  it 'should return middle name when middle name exists' do
    child_name = "First Middle Last"

    names = @task.split_name(child_name)

    names[:MiddleName].should == "Middle"
  end

  it 'should return all names between first and last as middle name' do
    child_name = "Child With Many Names"

    names = @task.split_name(child_name)

    names[:MiddleName].should == "With Many"
  end

  it 'should format file name' do
    record = {:id => 'b2dfc87'}

    filename = @task.format_filename(record)

    filename.should == "b2dfc87.xls"
  end

  it 'should add 1 to row after writing to excel ' do
    @task.row = 0
    @worksheet.stub!(:write_row).with(0, 0, [nil, nil, nil])

    @task.map_to_excel(nil, nil, nil)

    @task.row.should == 1
  end

end