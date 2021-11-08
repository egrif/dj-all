require 'forwardable'

module Dajoku
  class Domain
    extend Forwardable

    def_delegators :@value_hash, :visibility, :public

  end
end
