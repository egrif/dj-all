require 'dajoku/yaml_fetcher'
require 'dajoku/domain'
require 'dajoku/variable'
require 'dajoku/annotation'
require 'dajoku/component'

module Dajoku
  class Environment
    def initialize(application, space, name, region)
      @application = application
      @space = space
      @name = name
      @region = region
      @constituents = {}
    end

    attr_reader :application, :space, :name, :region

    def get_yaml(force_fetch = false)
      @yaml_fetcher = Dajoku::YamlFetcher.call(self, force_fetch: force_fetch)
      @yaml_fetcher.yaml
    end

    def yaml(force_fetch = false)
      @raw_yaml ||= get_yaml(force_fetch)
    end

    def refresh
      @raw_yaml = nil
      yaml(true)
    end

    def secrets
      rets = yaml['secrets'].map do |entry|
        Dajoku::Variable.new(entry['name'], entry, self)
      end
      return rets || []
    end

    def configs
      figs = yaml["configs"].map do |entry|
        Dajoku::Variable.new(entry['name'], entry, self)
      end
      return figs || []
    end

    def annotations
      yaml["annotations"].map do |entry|
        Dajoku::Annotation.new(entry['key'], entry['value'])
      end
    end

    def components
      yaml["component_settings"].map do |entry|
        Dajoku::Component.new(entry['key'], entry['value'])
      end
    end

    def domains
      yaml["domains"].map do |entry|
        Dajoku::Domain.new(entry['key'], entry['value'])
      end
    end
  end
end
