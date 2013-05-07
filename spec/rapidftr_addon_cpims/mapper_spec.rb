require 'spec_helper'

describe RapidftrAddonCpims::Mapper do

  describe "core functionality" do
    before :each do
      @mapper = build_child :_id => "test-id"
    end

    it 'should call original attribute' do
      @mapper._id.should == "test-id"
    end

    it 'should return true if attribute is present' do
      @mapper.present?("_id").should be_true
    end

    it 'should return false if attribute is not present' do
      @mapper.present?("xyz").should be_false
    end
  end

  describe "#name" do
    before :each do
      @mapper = build_child :name => "test1 test2 test3 test4"
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

  describe "#fathers_name" do
    before :each do
      @mapper = build_child :fathers_name => "test1 test2 test3 test4"
    end

    it 'should return first name' do
      @mapper.fathers_first_name.should == "test1"
    end

    it 'should return last name' do
      @mapper.fathers_last_name.should == "test4"
    end

    it 'should return middle name' do
      @mapper.fathers_middle_name.should == "test2 test3"
    end
  end

  describe "#mothers_name" do
    before :each do
      @mapper = build_child :mothers_name => "test1 test2 test3 test4"
    end

    it 'should return first name' do
      @mapper.mothers_first_name.should == "test1"
    end

    it 'should return last name' do
      @mapper.mothers_last_name.should == "test4"
    end

    it 'should return middle name' do
      @mapper.mothers_middle_name.should == "test2 test3"
    end
  end

  describe "#care_arrangments_name" do
    before :each do
      @mapper = build_child :care_arrangments_name => "test1 test2 test3 test4"
    end

    it 'should return first name' do
      @mapper.care_arrangments_first_name.should == "test1"
    end

    it 'should return last name' do
      @mapper.care_arrangments_last_name.should == "test4"
    end

    it 'should return middle name' do
      @mapper.care_arrangments_middle_name.should == "test2 test3"
    end
  end

end
