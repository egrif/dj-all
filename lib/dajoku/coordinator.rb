require 'ostruct'
require 'yaml'
require_relative './dajoku_environment'
require_relative './yaml_file'

module Dajoku
  class Coordinator

    YAML_DEFAULT_FOLDER = '/tmp'
    YAML_TTL = 600  # in seconds == 10 minutes

    def initialize(application)
      @application = application
      @obsolete = true
      @yamls = OpenStruct.new
    end

    def add_environment(space, name, region)
      @obsolete = true
      @envs ||= OpenStruct.new
      env = Dajoku::DajokuEnvironment.new(@application, space, name, region)
      key = env_key(env)
      @envs[key] = env
      @yamls[key] = nil unless @yamls.nil?
    end

    def call(force_fetch = false)
      @force_fetch = force_fetch
      fetch_yamls
      @obsolete = false
      merged_variables
    end

    def environments
      @envs.values
    end

    private

      def env_key(env)
        [env.application, env.name, env.space, env.region].join("-")
      end

      def fetch_yamls
        @envs.each_pair do |key, environment|
          yaml = Dajoku::YamlFile.new(environment).fetch_yaml(force_fetch: @force_fetch)
          @yamls[key] = yaml
        end
      end

      def merged_variables
        if @obsolete
          fetch_yamls
        end
        @yamls.to_h.values.reduce([]) { |aggregate,yaml| aggregate + yaml.variables }
      end

      def merged_and_grouped_variables
        merged_variables.
          sort_by(&:key).
          group_by(&:key)
      end

  end
end
