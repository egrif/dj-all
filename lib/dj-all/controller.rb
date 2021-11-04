require 'dajoku/coordinator.rb'

module DjAll

  # Couldn't think of a better name at the moment
  class Controller
    def initialize(dajoku_coordinator)
      @dajoku_coordinator = dajoku_coordinator
    end

    def self.new_from_params(application_string, environments_string_array)
      coordinator = Dajoku::Coordinator.new(application_string)
      environments_string_array.map { |e| coordinator.add_environment(*e) }
      new(coordinator)
    end

    def show_vars(variable_name, force_fetch = false)
      environment_variables = @dajoku_coordinator.call force_fetch
      filtered = environment_variables.select{ |v| File.fnmatch(variable_name, v.key) }
      by_tag = filtered.sort_by(&:name).group_by(&:name)
      by_key = filtered.sort_by(&:key).group_by(&:key)


      # hash of hashes
      by_tag_key = {}
      by_tag.each do |tag, vars|
        by_tag_key[tag] = vars.collect(&:key).zip(vars).to_h
      end

      # Output rows as arrays with config var name prepended
      rows = by_key.keys.map do |key|
        [key] + by_tag.keys.map do |tag|
          by_tag_key[tag][key]&.value
        end
      end

      # names, envirnoment names, rows
      puts output(by_key.keys, by_tag.keys, rows)

    end

    def format(tag,variables)
      OpenStruct.new(
        key => key,
        is_secret => variables.first.is_secret,
        values => variables.map { |v| OpenStruct.new( v.name => v.value )}
      )
    end

    def output(row_heads, col_heads, values)
      first_row = [''] + col_heads

      # column widths are the max width for each column (monospaced type)
      max_widths = first_row.map.with_index do |head, i|
        values.reduce(0) { |max, row| (row[i].nil? || max > row[i].length) ? max : row[i].length }
      end

      out_string_array = [out_format(first_row, max_widths, 2)]
      out_string_array += values.map{ |val_row| out_format(val_row, max_widths, 2)}
      return out_string_array.join("\n")
    end

    def out_format(row, widths, sep_width)
      out_row = row.map.with_index do |val, i|
        val = '' if val.nil?
        # left justified
        spaces_needed = widths[i] > val.length ? widths[i]-val.length : 0
        val + " " * spaces_needed
      end
      out_row.join(" " * sep_width)
    end

  end
end
