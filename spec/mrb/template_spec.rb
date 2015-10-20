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

  describe ".render_build_config_host" do
    it 'replaces class name if build target name is set' do
      text = Mrb::Template.render_build_config_host(
        {
          "name" => "aaa",
        }
      )
      expect(text).to include %q{MRuby::Build.new('aaa') do |conf|}
    end

    it 'replaces class name if toolchain is set' do
      text = Mrb::Template.render_build_config_host(
        {
          "name" => "host",
          "toolchain" => "bbb",
        }
      )
      expect(text).to include "toolchain :bbb"
    end

    it 'replaces class name if debug is enable' do
      text = Mrb::Template.render_build_config_host(
        {
          "name" => "host",
          "debug" => "enable",
        }
      )
      expect(text).to include 'enable_debug'
    end

    it 'replaces class name if debug is disable' do
      text = Mrb::Template.render_build_config_host(
        {
          "name" => "host",
          "debug" => "disable",
        }
      )
      expect(text).not_to include 'enable_debug'
    end

    it 'replaces class name if debug is not set' do
      text = Mrb::Template.render_build_config_host(
        {
          "name" => "host",
          "debug" => "",
        }
      )
      expect(text).not_to include 'enable_debug'
    end

    it 'replaces mrbgems if mrbgems library is set' do
      text = Mrb::Template.render_build_config_host(
        {
          "name" => "host",
          "gem"=> [
            'path/to/extension',
            { "github" => 'github-uri' },
          ],
        }
      )
      expect(text).to include "conf.gem 'path/to/extension'"
      expect(text).to include "conf.gem :github => 'github-uri'"
    end
  end
end
