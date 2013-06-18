require 'spec_helper'

describe RapidftrAddonCpims::Mapper do

  it 'should call original attribute' do
    mapper = build_child :_id => "test-id"
    mapper[:_id].should == "test-id"
  end

  describe "#name" do
    before :each do
      @mapper = build_child :name => "test1 test2 test3 test4"
    end

    it 'should return first name' do
      @mapper.first_name_from(:name).should == "test1"
    end

    it 'should return last name' do
      @mapper.last_name_from(:name).should == "test4"
    end

    it 'should return middle name' do
      @mapper.middle_name_from(:name).should == "test2 test3"
    end
  end

  describe '#date' do
    it 'should parse date from literal' do
      mapper = build_child :some_date => "the 25th of may 85"
      mapper.parse_date_from(:some_date).should == "25/05/1985"
    end

    it 'should parse date from formatted' do
      mapper = build_child :some_date => DateTime.new(1985, 5, 25).to_s
      mapper.date_from(:some_date).should == "25/05/1985"
    end
  end

  describe '#photo' do
    it 'should return photo' do
      mapper = build_child :current_photo_key => "photo"
      mapper.child.should_receive(:read_attachment).with("photo").and_return("one")

      io = double()
      StringIO.should_receive(:new).with("one").and_return(io)

      mapper.photo_data.should == io
    end
  end

end
