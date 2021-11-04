require 'juxtaconfig/controller'
#require 'dajoku/dajoku_environment'

module Juxtaconfig
  class Main
    def initialize(dajoku_environments)
      @dajoku_environments = dajoku_environments
    end

    def execute
      puts Juxtaconfig::Controller.new(@dajoku_environments).juxtapose
    end
  end
end
