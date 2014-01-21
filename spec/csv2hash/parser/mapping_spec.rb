require 'spec_helper'

describe Csv2hash::Parser::Mapping do

  let(:definition) do
    Csv2hash::Definition.new [ { position: [0,0], key: 'name' } ], Csv2hash::Definition::MAPPING
  end

  let(:data_source) { [ [ 'John Doe' ] ] }

  subject do
    Csv2hash.new(definition, 'file_path', false, data_source)
  end

  context 'regular way' do
    it { expect { subject.parse }.to_not raise_error }
    it {
      subject.tap do |csv2hash|
        csv2hash.parse
      end.data.should eql({ data: [ { 'name' => 'John Doe' } ] })
    }
  end

  context 'with nested' do
    let(:data_source) { [ [ 'John Doe', 22 ] ] }
    before do
      definition.rules << { position: [0,1], key: 'age', nested: 'infos' }
    end
    it {
      subject.tap { |c| c.parse }.data.should eql(
        { data: [ { 'name' => 'John Doe', 'infos' => { 'age' => 22 } } ] }
      )
    }
  end

  context 'allow blank' do
    let(:definition) do
      Csv2hash::Definition.new [ { position: [0,0], key: 'name' },
        { position: [0,1], key: 'surname', allow_blank: true },
       ], Csv2hash::Definition::MAPPING
    end

    before { subject.parse }

    context 'no field' do
      let(:data_source) { [ [ 'John Doe' ] ] }
      its(:errors) { should be_empty }
      its(:data) { should eql data: [ { 'name' => 'John Doe', 'surname' => nil} ] }
    end

    context 'field with nil value' do
      let(:data_source) { [ [ 'John Doe', nil  ] ] }
      its(:errors) { should be_empty }
      its(:data) { should eql data: [ { 'name' => 'John Doe', 'surname' => nil} ] }
    end

    context 'field with blank value' do
      let(:data_source) { [ [ 'John Doe', ''  ] ] }
      its(:errors) { should be_empty }
      its(:data) { should eql data: [ { 'name' => 'John Doe', 'surname' => ''} ] }
    end

  end

end