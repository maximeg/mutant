require 'spec_helper'

describe Mutant::Mutator, 'gvar' do

  before do
    Mutant::Random.stub(:hex_string => 'random')
  end

  let(:source) { '$a = nil; $a' }

  let(:mutations) do
    mutants = []
    mutants << '$a = nil; nil'
    mutants << '$a = nil'
    mutants << '$a'
    mutants << '$a = ::Object.new; $a'
    mutants << '$srandom = nil; $a'
  end

  it_should_behave_like 'a mutator'
end