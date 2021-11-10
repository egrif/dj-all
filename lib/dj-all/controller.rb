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

    def show_vars(variable_names, force_fetch = false, spreadsheet_col_delim = false)
      environment_variables = @dajoku_coordinator.call force_fetch
      filtered = environment_variables.select do |v|
        variable_names.any? do |vn|
          File.fnmatch(vn, v.key) if v.key
        end
      end
      by_tag = filtered.sort_by(&:environment_name).group_by(&:environment_name)
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
      puts output(by_key.keys, by_tag.keys, rows) unless spreadsheet_col_delim
      puts spreadsheet_output(by_key.keys, by_tag.keys, rows, spreadsheet_col_delim) if spreadsheet_col_delim

    end

    def format(tag,variables)
      OpenStruct.new(
        key => key,
        is_secret => variables.first.is_secret,
        values => variables.map { |v| OpenStruct.new( v.name => v.value )}
      )
    end

    def output(row_heads, col_heads, values)
      first_row = ['Var Name'] + col_heads

      # column widths are the max width for each column (monospaced type)
      max_widths = first_row.map.with_index do |head, i|
        ([first_row] + values).reduce(0) { |max, row| (row[i].nil? || max > row[i].length) ? max : row[i].length }
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

    def spreadsheet_output(row_heads, col_heads, values, col_delim)
      first_row = ['Var Name'] + col_heads

      ([first_row] + values).map {|r| r.join(col_delim)}.join("\n")
    end

  end
end
