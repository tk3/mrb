require 'thor'
require 'fileutils'
require 'yaml'
require "mrb/version"
require "mrb/config"

module Mrb
  class CLI < Thor
    MRB_CONFIG_PATH = ".mrb"

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

      FileUtils.mkdir_p "#{full_name}/#{MRB_CONFIG_PATH}"

      config = nil
      if File.exist? "#{full_name}/#{MRB_CONFIG_PATH}/config"
        config = Config.load "#{full_name}/#{MRB_CONFIG_PATH}/config"
      else
        config = Config.create "#{full_name}/#{MRB_CONFIG_PATH}/config"
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
    option :list, :aliases => :l
    def install(version = "")
      available_versions = %w(1.0.0 1.1.0 1.2.0 1.3.0 1.4.0 master)

      if options[:list]
        puts "available versions:"
        available_versions.each {|v| puts "  #{v}"}
        return
      end

      unless available_versions.include?(version)
        $stderr.puts "Error: Not supported version. version=#{version}"
        return
      end

      config = Config.load "#{MRB_CONFIG_PATH}/config"

      if File.directory? "#{MRB_CONFIG_PATH}/#{version}"
        $stderr.puts "Error: already exists path=#{MRB_CONFIG_PATH}/#{version}"
        return
      end

      config["current"]["version"] = version
      config["current"]["installed"] << version  unless config["current"]["installed"].include? version
      Config.save "#{MRB_CONFIG_PATH}/config", config

      system Util.git_clone_command(config["mruby"]["url"], version, MRB_CONFIG_PATH)
      invoke :rake, "", {}
    end

    desc "uninstall", "uninstall a specific mruby"
    def uninstall(version)
      config = Config.load "#{MRB_CONFIG_PATH}/config"
      unless config["current"]["installed"].include? version
        $stderr.puts "Error: not found. version=#{version}"
        return
      end

      print "Are you sure you want to remove mruby? (y/n): "
      answer = STDIN.gets.chomp
      unless answer == "y"
        $stderr.puts "cancel"
        return
      end

      config["current"]["version"] = ""  if config["current"]["version"] == version
      config["current"]["installed"] = config["current"]["installed"].delete_if {|v| v == version }
      Config.save "#{MRB_CONFIG_PATH}/config", config

      FileUtils.rm_rf "#{MRB_CONFIG_PATH}/#{version}"
      puts "done."
    end

    desc "versions", "list installed mruby version"
    def versions()
      config = Config.load "#{MRB_CONFIG_PATH}/config"
      current_version = config["current"]["version"]
      config["current"]["installed"].each do |version|
        if current_version == version
          print "* "
        else
          print "  "
        end
        puts "#{version} (set by #{MRB_CONFIG_PATH}/#{version})"
      end
    end

    desc "version", "show current mruby version"
    def version()
      config = Config.load "#{MRB_CONFIG_PATH}/config"
      version = config["current"]["version"]

      puts "#{version} (set by #{MRB_CONFIG_PATH}/#{version})"
    end

    desc "use", "switch mruby version"
    def use(version)
      config = Config.load "#{MRB_CONFIG_PATH}/config"
      unless config["current"]["installed"].include? version
        $stderr.puts "Error: not found. version=#{version}"
        return
      end

      config["current"]["version"] = version
      Config.save "#{MRB_CONFIG_PATH}/config", config

      invoke :version, "", {}
    end

    desc "test", "execute mruby test"
    def test()
      invoke :rake, "test"
    end

    desc "clean", "clean up build files"
    def clean()
      invoke :rake, "clean"
    end

    desc "rake", "execute mruby minirake task"
    def rake(task = "")
      config = Config.load "#{MRB_CONFIG_PATH}/config"
      version = config["current"]["version"]

      Dir.chdir("#{MRB_CONFIG_PATH}/#{version}") do
        system "MRUBY_CONFIG=../../mrb-build_config.rb ./minirake #{task}"
      end
    end
  end
end
