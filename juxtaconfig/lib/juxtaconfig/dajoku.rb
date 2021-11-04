require 'yaml'

module Juxtaconfig
  class Dajoku

    def get_dajoku_config(application, environment, space, region)
      command = "dajoku env export -s #{space} -e #{environment} -a #{application} -r #{region} --i-know-what-i-am-doing-with-plain-text-secrets 2>&1"
      stdout = `#{command}`

      if $?.exitstatus.zero?
        re = /filepath\:\s*(.*)$/
        matched = stdout.match(re)

        if matched
          file_path = matched[1]

          file_contents = File.read(file_path)

          # TODO: Probably should put this in an ensure block
          try_delete_file(file_path)

          YAML.load(file_contents)
        else
          raise "Could not find YAML path in standard output: #{stdout}"
        end
      else
        puts "Dajoku command failed"
        puts "#{stdout}"
      end
    end


    def try_delete_file(file_name)
      begin
        File.delete(file_name)
      rescue StandardError
      end
    end

  end
end
