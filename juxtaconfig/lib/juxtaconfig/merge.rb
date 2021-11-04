module Juxtaconfig
  class MergeHashes
    class << self

      TAG_KEY = "__tag"

      # This method accepts an array of hashes where each hash is assumed to have the same
      # keys. In addition, it is required that each hash have a key called `__tag` where
      # the value (a String) represents what a parent value. For example, a tag could be called
      # "prod-s4" to represent that it came from "prod-s4".
      #
      # The `group_by_key` is the key that will be used to group the hashes together. This
      # should represent an identity. For example, if the hashes are components then the
      # group_by_key should be the component name. If the hashes are environment variables
      # then the `group_by_key` would be the name of the environment variable. Another way
      # to think about it is that all hashes in the same group should be merged together.
      #
      # Returns an array of hashes where each hash in the same group will be merged together.
      #
      # Note: This method is not recursive and will only merge keys on the first level.
      def merge(hashes, group_by_key)
        keys = hashes.first.keys
        distinct_tags = hashes.map { |hash| hash[TAG_KEY] }.uniq
        placeholder_value = "????"

        grouped_hashes = hashes.group_by { |hash| hash[group_by_key] }

        grouped_hashes.map do |_, group|
          result_hash = Hash.new
          keys.each do |key|
            next if key == TAG_KEY

            values = group.map { |hash| hash[key] }
            all_tags_have_values = distinct_tags.size == values.size
            all_values_equal = all_equal?(values)

            if all_tags_have_values
              if all_values_equal
                result_hash[key] = values.first
              else
                juxtaposed_hash = make_juxtaposed_hash_if_possible(key, group, group_by_key)
                result_hash.merge!({key => placeholder_value}, juxtaposed_hash)
              end
            else
              juxtaposed_hash = make_juxtaposed_hash_if_possible(key, group, group_by_key)
              if all_values_equal
                # If all the value are equal but not every tag possibility is represented,
                # then use the value but also show what the values are for the other tags
                result_hash.merge!({key => values.first}, juxtaposed_hash)
              else
                result_hash.merge!({key => placeholder_value}, juxtaposed_hash)
              end
            end
          end
          result_hash
        end
      end

      private

      def all_equal?(arr)
        arr.uniq.size <= 1
      end

      # Creates a merged hash based on the key. This
      # hash represents all of the other key values
      # from each hash into one hash.
      def make_juxtaposed_hash(key, hashes)
        result_hash = Hash.new
        hashes.each do |hash|
          new_key = "___#{key}___#{hash[TAG_KEY]}"
          result_hash[new_key] = hash[key]
        end
        result_hash
      end

      # There is one reason we wouldn't want to make a juxtaposed hash
      # and that is if we are doing it for the group_by_key. Because by
      # definition, they are already merged by that key and therefore showing
      # a juxtaposed version based on that key, conveys no new information.
      def make_juxtaposed_hash_if_possible(key, group, group_by_key)
        if key != group_by_key
          make_juxtaposed_hash(key, group)
        else
          {}
        end
      end
    end
  end
end
