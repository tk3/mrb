require 'spec_helper'

describe Mrb::Util do
  describe ".gen_names" do
    it 'returns various names if name is prefix' do
      variables = Mrb::Util.gen_names('mruby-aaa')
      expect(variables[:name]).to eq('aaa')
      expect(variables[:full_name]).to eq('mruby-aaa')
      expect(variables[:internal_name]).to eq('mruby_aaa')
    end

    it 'returns various names if name is no prefix' do
      variables = Mrb::Util.gen_names('aaa')
      expect(variables[:name]).to eq('aaa')
      expect(variables[:full_name]).to eq('mruby-aaa')
      expect(variables[:internal_name]).to eq('mruby_aaa')
    end
  end
end
