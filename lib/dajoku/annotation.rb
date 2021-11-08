require 'forwardable'

module Dajoku
  class Annotation < Dajoku::Constituent
    extend Forwardable
    def_delegators :@value_hash, :value
    def initialize(key, value, environment)
      value_hash = {value: value}
      super key, value_hash, environment
    end
  end
end
