require 'juxtaconfig/dajoku'
require 'juxtaconfig/merge'
require 'juxtaconfig/yaml'

module Juxtaconfig

  # Couldn't think of a better name at the moment
  class Controller
    def initialize(dajoku_environments)
      @dajoku_environments = dajoku_environments
    end

    def self.new_from_params(application_string, environments_string_array)
      coordinator = Dajoku::Coordinator.new(application_string)
      environments_string_array.map { |e| coordinator.add_environment(*e) }
      new(coordinator)
    end

    ###
    # dajoku_environments = [
    #   Juxtaconfig::DajokuEnvironment.new("greenhouse", "prod", "canary", "use1"),
    #   Juxtaconfig::DajokuEnvironment.new("greenhouse", "prod", "prod", "use1"),
    #   Juxtaconfig::DajokuEnvironment.new("greenhouse", "prod", "prod-s2", "use1"),
    #   Juxtaconfig::DajokuEnvironment.new("greenhouse", "prod", "prod-s3", "use1"),
    #   Juxtaconfig::DajokuEnvironment.new("greenhouse", "prod", "prod-s4", "use1")
    # ]
    def juxtapose
      dajoku = Juxtaconfig::Dajoku.new

      all_configs = @dajoku_environments.map do |dajoku_environment|
        dajoku_config = dajoku.get_dajoku_config(
          dajoku_environment.application,
          dajoku_environment.name,
          dajoku_environment.space,
          dajoku_environment.region
        )

        tag = dajoku_environment.name

        configs = dajoku_config["configs"].map { |config| tag_hash(config, tag) }
        secrets = dajoku_config["secrets"].map { |config| tag_hash(config, tag) }
        component_settings = dajoku_config["component_settings"].map do |component_name, component_setting|
          component_setting["component_name"] = component_name
          tag_hash(component_setting, tag)
        end
        annotations = [tag_hash(dajoku_config["annotations"], tag)]

        {
          "configs" => configs,
          "secrets" => secrets,
          "component_settings" => component_settings,
          "annotations" => annotations
        }
      end

      combined_configs_hash = all_configs.reduce(Hash.new) do |result, each_config|
        result.merge(each_config) do |_, leftval, rightval|
          leftval ||= []
          rightval ||= []
          leftval + rightval
        end
      end

      merged_configs_hash = {
        "configs" => merge_hashes(combined_configs_hash["configs"], "name"),
        "secrets" => merge_hashes(combined_configs_hash["secrets"], "name"),
        "component_settings" => merge_hashes(combined_configs_hash["component_settings"], "component_name"),
        "annotations" => merge_hashes(combined_configs_hash["annotations"], "NOOP"),
      }

      Juxtapose::Yaml.new.to_yaml(
        merged_configs_hash["configs"],
        merged_configs_hash["secrets"],
        merged_configs_hash["component_settings"],
        merged_configs_hash["annotations"]
      )
    end

    private

    def merge_hashes(hashes, group_by_key)
      Juxtaconfig::MergeHashes.merge(hashes, group_by_key)
    end

    def tag_hash(hash, tag)
      hash["__tag"] = tag
      hash
    end
  end
end
