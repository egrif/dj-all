require 'ostruct'
require 'yaml'
require_relative './environment_variable'

module Dajoku
  class YamlFile
    YAML_TTL = 600 # seconds a yaml file is considered to be valid
    YAML_DEFAULT_FOLDER = '/tmp'
    attr_reader :file_name, :timestamp, :created_at, :yaml

    def initialize(env)
      @environment = env
    end

    def fetch_yaml(force_fetch: false, delete_file: false, ttl: YAML_TTL)
      env = @environment
      file_name = nil
      file_name = Dir.glob("#{YAML_DEFAULT_FOLDER}/#{yaml_key(env)}").sort.pop unless force_fetch
      if file_name.nil? || expired?(yaml_date(file_name), ttl)
        command = "dajoku env export -s #{env.space} -e #{env.name} -a #{env.application} -r #{env.region} --i-know-what-i-am-doing-with-plain-text-secrets 2>&1"
        stdout = `#{command}`
        if $?.exitstatus.zero?
          re = /filepath\:\s*(.*)$/
          matched = stdout.match(re)
          if matched
            file_name = matched[1]
          end
        end
      end
      yaml_deets(file_name) unless file_name.nil?
      self
    ensure
      try_delete(file_name) if !file_name.nil? && delete_file
    end

    def variables
      configs + secrets
    end

    def expired?(time = nil, ttl = YAML_TTL)
      time ||= @created_at
      time.to_i + ttl < Time.now.to_i
    end

    def self.extant_yamls(env)
      Dir("#{YAML_DEFAULT_FOLDER}/#{yaml_key(env)}")
    end

    private

      def configs
        @yaml["configs"].map do |config|
          key = config["name"]
          value = config["value"]
          Dajoku::EnvironmentVariable.new(key, value, false, variable_tag)
        end
      end

      def secrets
        @yaml["secrets"].map do |secret|
          key = secret["name"]
          # TODO: When TOPS allows the nonencrypted value, this will need to be changed
          value = secret["encrypted_value"]
          Dajoku::EnvironmentVariable.new(key, value, true, variable_tag)
        end
      end

      def variable_tag
        "#{@environment.space}_#{@environment.name}_#{@environment.region}"
      end

      def yaml_deets(file_name)
        @created_at = yaml_date(file_name)
        @file_name = file_name
        @timestamp = yaml_timestamp(file_name)
        @yaml = YAML.load(File.read(file_name))
      end

      def string_to_time(str)
        vals = str.chars.each_slice(2).map(&:join)
        Time.new(vals[0] + vals[1], vals[2], vals[3], vals[4], vals[5], vals[6])
      end

      def yaml_key(env = nil)
        env ||= @environment
        env = OpenStruct.new(env) unless env.respond_to?(:application)
        "#{env.application || '*'}-#{env.name || '*'}-#{env.space || '*'}-*.yml"
      end

      def yaml_date(file = nil)
        file ||= @file_name
        string_to_time(yaml_timestamp(file))
      end

      def yaml_timestamp(file = nil)
        file ||= @file_name
        # more robust /\d{14,14}/  ?
        file.split("-").pop.gsub(".yml",'')
      end

      def try_delete_file(file_name)
        begin
          File.delete(file_name)
        rescue StandardError
        end
      end

  end
end
