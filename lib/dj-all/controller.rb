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

    def show_vars(variable_names, options)
      environment_variables = @dajoku_coordinator.call options[:force_fetch]
      filtered = environment_variables.select do |v|
        variable_names.any? do |vn|
          File.fnmatch(vn, v.key) if v.key
        end
      end
      group_rows_by = options[:pivot] ? :environment_name : :key
      group_columns_by = options[:pivot] ? :key : :environment_name
      columns = filtered.sort_by(&group_columns_by).group_by(&group_columns_by)
      row_objects = filtered.sort_by(&group_rows_by).group_by(&group_rows_by)


      # hash of hashes
      column_and_row = {}
      columns.each do |header, vars|
        column_and_row[header] = vars.collect(&group_rows_by).zip(vars).to_h
      end

      # Output rows as arrays with config var name prepended
      rows = row_objects.keys.map do |row_head|
        [row_head] + columns.keys.map do |col_head|
          column_and_row[col_head][row_head]&.value
        end
      end

      # names, envirnoment names, rows
      puts output(row_objects.keys, columns.keys, rows) unless options[:spreadsheet_formatting]
      puts spreadsheet_output(row_objects.keys, columns.keys, rows, options[:spreadsheet_formatting]) if options[:spreadsheet_formatting]

    end

    def format(tag,variables)
      OpenStruct.new(
        key => key,
        is_secret => variables.first.is_secret,
        values => variables.map { |v| OpenStruct.new( v.name => v.value )}
      )
    end

    def output(row_heads, col_heads, values)
      first_row = ['Name'] + col_heads

      # column widths are the max width for each column (monospaced type)
      max_widths = first_row.map.with_index do |head, i|
        ([first_row] + values).reduce(0) { |max, row| (row[i].nil? || max > row[i].length) ? max : row[i].length }
      end

      out_string_array = [out_format(first_row, max_widths, 2, Settings::DJALL.formatting.colors.first_row)]
      stripe_count = Settings::DJALL.formatting.colors.striping.length ? Settings::DJALL.formatting.colors.striping.length : 0
      out_string_array += values.map.with_index do |val_row, i|
        color = stripe_count == 0 ? nil : Settings::DJALL.formatting.colors.striping[i % stripe_count]
        out_format(val_row, max_widths, 2, color, Settings::DJALL.formatting.colors.first_column)
      end
      return out_string_array.join("\n")
    end

    def out_format(row, widths, sep_width, row_color = nil, first_column_color = nil)
      row_color = '' if !row_color.is_a?(String)
      row_reset = row_color == '' ? '' : "\e[0m"
      first_column_color = '' if !first_column_color.is_a?(String)
      out_row = row.map.with_index do |val, i|
        val = '' if val.nil?
        # left justified
        spaces_needed = widths[i] > val.length ? widths[i]-val.length : 0
        val = first_column_color + val + "\e[0m" if i == 0 && !first_column_color.empty?
        val + " " * spaces_needed
      end
      row_color + out_row.join(" " * sep_width) + row_reset
    end

    def spreadsheet_output(row_heads, col_heads, values, col_delim)
      first_row = ['Name'] + col_heads

      ([first_row] + values).map {|r| r.join(col_delim)}.join("\n")
    end

  end
end
