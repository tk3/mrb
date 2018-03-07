require "yaml"

module Mrb
  class Config
    DEFAULT_CONFIG = {
      "mruby" => {
        "url" => "https://github.com/mruby/mruby.git",
        "tag" => []
      },
      "current" => {
        "version" => "",
        "installed" => []
      }
    }

    def self.create(config_path)
      File.open(config_path, "w") do |fout|
        YAML.dump(DEFAULT_CONFIG, fout)
      end
      DEFAULT_CONFIG
    end

    def self.load(config_path)
      YAML.load_file(config_path)
    end

    def self.save(config_path, config)
      File.open(config_path, "w") do |fout|
        YAML.dump(config, fout)
      end
    end
  end
end

