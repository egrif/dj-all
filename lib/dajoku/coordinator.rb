require 'ostruct'
require 'yaml'
require 'dajoku/environment'
require 'dajoku/yaml_fetcher'

module Dajoku
  class Coordinator

    YAML_DEFAULT_FOLDER = '/tmp'
    YAML_TTL = 600  # in seconds == 10 minutes

    def initialize(application)
      @application = application
      @yamls = OpenStruct.new
    end

    def add_environment(space, name, region)
      @envs ||= OpenStruct.new
      env = Dajoku::Environment.new(@application, space, name, region)
      key = generated_key(env)
      @envs[key] = env
    end

    def call(force_fetch = false)
      merged_variables force_fetch
    end

    def environments
      @envs.values
    end

    private

      def generated_key(env)
        [env.application, env.name, env.space, env.region].join("-")
      end

      def merged_variables(force_fetch = false)
        @envs.to_h.values.reduce([]) do |aggregate, env|
          env.refresh if force_fetch
          aggregate + env.secrets + env.configs
        end
      end

      def merged_and_grouped_variables
        merged_variables.
          sort_by(&:key).
          group_by(&:key)
      end

  end
end
