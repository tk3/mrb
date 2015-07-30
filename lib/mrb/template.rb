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
  end
end
