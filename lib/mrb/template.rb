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

    private
    def self.config_to_binding(config)
      config = {}  unless config.is_a?(Hash)
      config['name'] = {}  unless config.is_a?(Hash)
      binding
    end
  end
end
