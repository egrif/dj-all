require 'ostruct'
require 'yaml'
require 'json'

module Settings
  DJALL = JSON.parse(
    YAML.load(File.read(File.join(__dir__, 'dj-all.yml'))).merge(
      File.file?(ENV.fetch('DJALL_CONFIG_FILE',"#{ENV['HOME']}/.dj-all.yml")) ? YAML.load(File.read(ENV.fetch('DJALL_CONFIG_FILE',"#{ENV['HOME']}/.dj-all.yml"))) : {}
    ).merge({
      secret_password: ENV.fetch('DJ_ALL_SECRET_PASSWORD', nil)
    }).to_json, object_class: OpenStruct)
end
