module Dajoku
  class Domain

    delegate :visibility, :public, to: :value, allow_nil: true

    def initialize(key, value, environment)
      value = OpenStruct.new(value)
    end

  end
end
