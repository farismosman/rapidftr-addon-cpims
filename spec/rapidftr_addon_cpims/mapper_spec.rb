require 'spec_helper'

describe RapidftrAddonCpims::Mapper do
  before :each do
    @mapper = RapidftrAddonCpims::Mapper.new "name" => "test1 test2 test3 test4"
  end

  it 'should call original attribute' do
    @mapper.name.should == "test1 test2 test3 test4"
  end

  it 'should return true if attribute is present' do
    @mapper.present?("name").should be_true
  end

  it 'should return false if attribute is not present' do
    @mapper.present?("xyz").should be_false
  end

  it 'should return first name' do
    @mapper.first_name.should == "test1"
  end

  it 'should return last name' do
    @mapper.last_name.should == "test4"
  end

  it 'should return middle name' do
    @mapper.middle_name.should == "test2 test3"
  end

end
