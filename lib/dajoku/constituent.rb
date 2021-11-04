require 'forwardable'

module Dajoku
  class Constituent
    extend Forwardable

    def_delegators :@environment, :name, :space, :region, :application

    def initialize(key, value, environment)
      @key = key
      @value = value
      @environment = environment
    end

    attr_reader :key, :value, :environment
  end
end
