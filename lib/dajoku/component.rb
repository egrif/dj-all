require 'forwardable'

module Dajoku
  class Component
    extend Forwardable

    def_delegators :@value_hash, :count, :min_count, :max_count, :cpus, :limit_cpus, :memory, :limit_memory, :autoscaling, :worker_type_preferred, :worker_type_required

  end
end
