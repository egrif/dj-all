module Dajoku
  class Environment
    def initialize(application, space, name, region)
      @application = application
      @space = space
      @name = name
      @region = region
    end

    attr_reader :application, :space, :name, :region
  end
end
