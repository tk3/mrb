require 'spec_helper'

describe Mrb::Template do
  describe ".render_readme" do
    it 'generates the README file' do
      expect(Mrb::Template.render_readme({})).not_to be_empty
    end
  end

  describe ".render_mrbgem" do
    it 'replaces mrbgem name if variable is set' do
      text = Mrb::Template.render_mrbgem({:full_name => 'mruby-aaa'})
      expect(text).to include "MRuby::Gem::Specification.new('mruby-aaa')"
    end
  end

  describe ".render_example_c" do
    it 'replaces mrbgem name if variable is set' do
      text = Mrb::Template.render_mrbgem({:full_name => 'mruby-aaa'})
      expect(text).to include "MRuby::Gem::Specification.new('mruby-aaa')"
    end
  end

  describe ".render_example_c" do
    it 'replaces gem name if variable is set' do
      text = Mrb::Template.render_example_c({:name => 'aaa', :internal_name => 'mruby_aaa'})
      expect(text).to include 'mrb_mruby_aaa_gem_init(mrb_state* mrb) {'
      expect(text).to include 'struct RClass *class_aaa = mrb_define_module(mrb, "Aaa");'
      expect(text).to include 'mrb_mruby_aaa_gem_final(mrb_state* mrb) {'
    end
  end

  describe ".render_test_example_c" do
    it 'replaces function name if variable is set' do
      text = Mrb::Template.render_test_example_c({:name => 'aaa'})
      expect(text).to include 'mrb_aaa_gem_test(mrb_state *mrb)'
    end
  end

  describe ".render_test_example_rb" do
    it 'replaces class name if variable is set' do
      text = Mrb::Template.render_test_example_rb({:name => 'aaa'})
      expect(text).to include 'Aaa.respond_to?'
    end
  end
end
