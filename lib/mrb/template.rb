require 'erb'

module Mrb
  class Template
    def self.read(name)
      assets_template_path = File.expand_path('../../../assets/templates', __FILE__)
      File.read(assets_template_path + '/' + name)
    end

    def self.render(name, variables)
      ERB.new(self.read(name)).result(binding)
    end

    def self.render_config(name, variables)
      b = config_to_binding(variables)
      ERB.new(self.read(name)).result(b)
    end

    def self.render_readme(variables)
      render('gem/README.md.erb', variables)
    end

    def self.render_mrbgem(variables)
      render('gem/mrbgem.rake.erb', variables)
    end

    def self.render_mrb_build_config(variables)
      render('gem/build_config.rb.erb', variables)
    end

    def self.render_example_c(variables)
      render('gem/example.c.erb', variables)
    end

    def self.render_test_example_c(variables)
      render('gem/test_example.c.erb', variables)
    end

    def self.render_test_example_rb(variables)
      render('gem/test_example.rb.erb', variables)
    end

    def self.render_build_config_host(config)
      render_config('config/build_config_host.erb', config)
    end

    def self.render_build_config_crossbuild(config)
      render_config('config/build_config_crossbuild.erb', config)
    end

    private
    def self.config_to_binding(config)
      config = {}  unless config.is_a?(Hash)
      config['name'] = {}  unless config.is_a?(Hash)
      binding
    end
  end
end
