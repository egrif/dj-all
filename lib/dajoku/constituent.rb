module Dajoku
  class Constituent

    delegate :name, :space, :region, :application, to: :environment, allow_nil: true

    def initialize(key, value, environment)
      @key = key
      @value = value
      @environment = environment
    end

    attr_reader :key, :value, :environment
  end
end
