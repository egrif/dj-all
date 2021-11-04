module Dajoku
  class Component

    delegate :count, :min_count, :max_count, :cpus, :limit_cpus, :memory, :limit_memory, :autoscaling, :worker_type_preferred, :worker_type_required,
      to: :value, allow_nil: true

    def initialize(key, value, environment)
      value = OpenStruct.new(value)
      super
    end

  end
end
