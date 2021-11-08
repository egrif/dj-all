require "dajoku/constituent"
require 'forwardable'

module Dajoku
  class Variable < Dajoku::Constituent
    extend Forwardable

    def_delegators :@value_hash, :is_secret?, :value, :encrypted_value, :name

    def initialize(key, value_hash, environment)
      value_hash['is_secret?'] = value_hash.has_key?('encrypted_value')
      super key, value_hash, environment
    end
  end
end
