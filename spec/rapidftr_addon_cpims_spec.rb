require 'spec_helper'

describe RapidftrAddonCpims::Task do

  before(:each) do
    @task = RapidftrAddonCpims::Task.new
  end

  it 'should split child name to first name and last name' do
    child_name = "Some Random Name"

    names = @task.split_child_name(child_name)

    names[:FirstName].should == 'Some'
    names[:LastName].should == 'Name'
  end

  it 'should return empty string when middle name does not exist' do
    child_name = "First Last"

    names = @task.split_child_name(child_name)

    names[:MiddleName].should == ""
  end

  it 'should return middle name when middle name exists' do
    child_name = "First Middle Last"

    names = @task.split_child_name(child_name)

    names[:MiddleName].should == "Middle"
  end

end