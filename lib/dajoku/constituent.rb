require 'forwardable'
require 'ostruct'

module Dajoku
  class Constituent
    extend Forwardable

    def_delegators :@environment, :space, :region, :application

    def initialize(key, value_hash, environment)
      @key = key
      @value_hash = OpenStruct.new(value_hash)
      @environment = environment
    end

    def environment_name
      @environment.name
    end

    attr_reader :key, :value_hash, :environment
  end
end
