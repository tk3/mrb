require 'thor'
require 'fileutils'
require 'yaml'
require "mrb/version"
require "mrb/config"

module Mrb
  class CLI < Thor
    desc "get", "get mruby source code"
    def get()
      %x{git clone https://github.com/mruby/mruby.git}
    end

    desc "gem NAME", "create necessary files, directory constitution"
    def gem(name)
      variables = Util.gen_names(name)
      full_name = variables[:full_name]

      FileUtils.mkdir_p full_name
      puts "Creating gem '#{full_name}'..."

      mrb_config_path_name = ".mrb"
      FileUtils.mkdir_p "#{full_name}/#{mrb_config_path_name}"

      config = nil
      if File.exist? "#{full_name}/#{mrb_config_path_name}/config"
        config = Config.load "#{full_name}/#{mrb_config_path_name}/config"
      else
        config = Config.create "#{full_name}/#{mrb_config_path_name}/config"
      end

      File.write "#{full_name}/README.md", Mrb::Template.render_readme(variables)
      puts "  create #{full_name}/README.md"
      File.write "#{full_name}/mrbgem.rake", Mrb::Template.render_mrbgem(variables)
      puts "  create #{full_name}/mrbgem.rake"
      File.write "#{full_name}/mrb-build_config.rb", Mrb::Template.render_mrb_build_config(variables)
      puts "  create #{full_name}/mrb-build_config.rb"

      FileUtils.mkdir_p "#{full_name}/src"
      File.write "#{full_name}/src/example.c", Mrb::Template.render_example_c(variables)
      puts "  create #{full_name}/src/example.c"

      FileUtils.mkdir_p "#{full_name}/test"
      File.write "#{full_name}/test/example.c", Mrb::Template.render_test_example_c(variables)
      puts "  create #{full_name}/test/example.c"
      File.write "#{full_name}/test/example.rb", Mrb::Template.render_test_example_rb(variables)
      puts "  create #{full_name}/test/example.rb"
    end

    desc "config yml", "create mruby build config"
    def config(file)
      yaml = YAML.load_file(file)

      unless yaml.is_a?(Hash)
        # minimize_config
        yaml = {
          'build' => {
            'host' => {
              'toolchain' => 'gcc',
              'gembox'    => 'default',
            }
          }
        }
      end

      text = ''
      if yaml.key?('build')
        yaml['build'].keys.each do |name|
          config = yaml['build'][name]
          config['name'] = name
          text << Mrb::Template.render_build_config_host(config)
        end
      end

      if yaml.key?('crossbuild')
        yaml['crossbuild'].keys.each do |name|
          config = yaml['crossbuild'][name]
          config['name'] = name
          text << Mrb::Template.render_build_config_crossbuild(config)
        end
      end

      puts "Creating build_config.rb"
      File.write "./build_config.rb", text.gsub(/^$\n/, '')
    end

    desc "build", "build mruby"
    def build(file)
      yaml = YAML.load_file(file)

      if !yaml.is_a?(Hash) || !yaml.key?('mruby')
        $stderr.puts 'Error: Not found mruby location.'
        return
      end

      if yaml['mruby'].key?('github')
        github_path = yaml['mruby']['github']
        %x{git clone https://github.com/#{github_path}.git}
        mruby_path = './mruby'
      elsif yaml['mruby'].key?('path')
        mruby_path = yaml['mruby']['path']
      end

      puts "Buildding ..."
      file_path = File.expand_path(file)
      Dir.chdir(mruby_path) do
        config file_path
        %x{rake}
      end
    end

    desc "install", "install mruby"
    option :list
    def install(version = "")
      available_versions = %w(1.0.0 1.1.0 1.2.0 1.3.0 1.4.0 master)

      mrb_config_path_name = ".mrb"
      config = Config.load "#{mrb_config_path_name}/config"

      if options[:list]
        puts "available versions:"
        available_versions.each {|v| puts "  #{v}"}
        return
      end

      unless available_versions.include?(version)
        $stderr.puts "Error: Not supported version. version=#{version}"
        return
      end

      system "git clone #{config["mruby"]["url"]} #{mrb_config_path_name}/#{version}"
      Dir.chdir("#{mrb_config_path_name}/#{version}") do
        system "MRUBY_CONFIG=../../mrb-build_config.rb ./minirake"
      end

      config["current"]["version"] = version
      Config.save "#{mrb_config_path_name}/config", config
    end

    desc "test", "execute mruby test"
    def test()
      mrb_config_path_name = ".mrb"
      config = Config.load "#{mrb_config_path_name}/config"
      version = config["current"]["version"]

      Dir.chdir("#{mrb_config_path_name}/#{version}") do
        system "MRUBY_CONFIG=../../mrb-build_config.rb ./minirake test"
      end
    end

    desc "clean", "clean up build files"
    def clean()
      mrb_config_path_name = ".mrb"
      config = Config.load "#{mrb_config_path_name}/config"
      version = config["current"]["version"]

      Dir.chdir("#{mrb_config_path_name}/#{version}") do
        system "MRUBY_CONFIG=../../mrb-build_config.rb ./minirake clean"
      end
    end


    desc "version", "show version number"
    def version()
      puts Mrb::VERSION
    end
  end
end
