require 'test/unit'
require "mrb"

class MrbTemplateTest < Test::Unit::TestCase
  def test_render_readme
    assert(!Mrb::Template.render_readme({}).empty?)
  end

  def test_render_mrbgem
    text = Mrb::Template.render_mrbgem({:full_name => 'mruby-aaa'})
    assert(text.include?("MRuby::Gem::Specification.new('mruby-aaa')"))
  end

  def test_render_example_c_1
    text = Mrb::Template.render_mrbgem({:full_name => 'mruby-aaa'})
    assert(text.include?("MRuby::Gem::Specification.new('mruby-aaa')"))
  end

  def test_render_example_c_2
    text = Mrb::Template.render_example_c({:name => 'aaa', :internal_name => 'mruby_aaa'})
    assert(text.include?('mrb_mruby_aaa_gem_init(mrb_state* mrb) {'))
    assert(text.include?('struct RClass *class_aaa = mrb_define_module(mrb, "Aaa");'))
    assert(text.include?('mrb_mruby_aaa_gem_final(mrb_state* mrb) {'))
  end

  def test_render_test_example_c
    text = Mrb::Template.render_test_example_c({:name => 'aaa'})
    assert(text.include?('mrb__gem_test(mrb_state *mrb)'))
  end

  def test_render_test_example_rb
    text = Mrb::Template.render_test_example_rb({:name => 'aaa'})
    assert(text.include?('Aaa.respond_to?'))
  end

  # describe ".render_build_config_host" do
  def test_build_host_1
    text = Mrb::Template.render_build_config_host(
      {
        "name" => "aaa",
      }
    )
    assert(text.include?(%q{MRuby::Build.new('aaa') do |conf|}))
  end

  def test_build_host_2
    text = Mrb::Template.render_build_config_host(
      {
        "name" => "host",
        "toolchain" => "bbb",
      }
    )
    assert(text.include?("toolchain :bbb"))
  end

  def test_build_host_3
    text = Mrb::Template.render_build_config_host(
      {
        "name" => "host",
        "debug" => "enable",
      }
    )
    assert(text.include?('enable_debug'))
  end

  def test_build_host_4
    text = Mrb::Template.render_build_config_host(
      {
        "name" => "host",
        "debug" => "disable",
      }
    )
    assert(!text.include?('enable_debug'))
  end

  def test_build_host_5
    text = Mrb::Template.render_build_config_host(
      {
        "name" => "host",
        "debug" => "",
      }
    )
    assert(!text.include?('enable_debug'))
  end

  def test_build_host_6
    text = Mrb::Template.render_build_config_host(
      {
        "name" => "host",
        "gem"=> [
          'path/to/extension',
          { "github" => 'github-uri' },
        ],
      }
    )
    assert(text.include?("conf.gem 'path/to/extension'"))
    assert(text.include?("conf.gem :github => 'github-uri'"))
  end
end
