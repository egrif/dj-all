module Juxtapose
  class Yaml
    LINE_BREAK_TOKEN = "{{LINE_BREAK}}"

    def to_yaml(configs, secrets, component_settings, annotations)
      document = {
        "exported_application" => "IGNORED",
        "exported_environment" => "IGNORED",
        "exported_region" => "IGNORED",
        "exported_space" => "IGNORED",

        "configs" => format_configs(configs),
        "secrets" => format_configs(secrets),
        "component_settings" => format_component_settings(component_settings),
        "domains" => {},
        "annotations" => annotations,
        "attributes" => { "iam_role" => nil }
      }

      lines = document.to_yaml.lines.map do |line|
        if line.include?(LINE_BREAK_TOKEN)
          "\n"
        else
          line
        end
      end

      lines.join
    end

    private

    def format_configs(configs)
      formatted = format(configs, "name")
      add_line_breaks(formatted)
    end

    def format_component_settings(component_settings)
      title_key = "component_name"

      formatted = format(component_settings, title_key).map do |component_setting|
        title = component_setting.delete(title_key)
        { title => component_setting }
      end

      add_line_breaks(formatted)
    end

    def format(hashes, sort_by_key)
      hashes.map { |hash| reorder_hash(hash, sort_by_key) }.sort_by { |hash| hash[sort_by_key]}
    end

    def reorder_hash(hash, title_key)
      keys_sorted = sort_keys(hash.keys)

      result_hash = Hash.new
      result_hash[title_key] = hash[title_key]
      keys_sorted.each do |key|
        result_hash[key] = hash[key] if key != title_key
      end

      result_hash
    end

    # Sorts the keys of a hash in a specific way for the purposes
    # of formatting the hash to YAML. All conflicting keys will get
    # grouped with the original parent key.
    def sort_keys(keys)
      keys_grouped = keys.group_by do |key|
        if key.start_with?("___")
          key.split("___")[1]
        else
          key
        end
      end

      sorted = keys_grouped.sort_by { |key, _| key }

      sorted.flat_map do |_, key_group|
        key_group.sort_by do |key|
          # TODO: Pad any numbers with zeroes
          if !key.start_with?("___")
            # This will guarantee that the non-underscored key will come first
            "!#{key}"
          else
            key
          end
        end
      end
    end

    def add_line_breaks(hashes)
      hashes.flat_map { |hash| [LINE_BREAK_TOKEN, hash] }
    end
  end
end
