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
    end

    attr_reader :application, :space, :name, :region

    def populate_details
      @yaml_fetcher = Dajoku::YamlFetcher.call(self)
      @raw_yaml = yaml.yaml
    end

    def secrets
      @raw_yaml['secrets'].map do |entry|
        Dajoku::Variable.new(entry['key'], entry['value'], self)
      end
    end


    def configs
      @raw_yaml["configs"].map do |entry|
        Dajoku::Variable.new(entry['key'], entry['value'], self)
      end
    end

    def annotations
      @raw_yaml["annotations"].map do |entry|
        Dajoku::Annotation.new(entry['key'], entry['value'], self)
      end
    end

    def components
      @raw_yaml["component_settings"].map do |entry|
        Dajoku::Component.new(entry['key'], entry['value'], self)
      end
    end

    def domains
      @raw_yaml["domains"].map do |entry|
        Dajoku::Domain.new(entry['key'], entry['value'], self)
      end
    end
  end
end
