require 'ostruct'
require 'yaml'
require 'dajoku/variable'
require 'settings/dj-all'

module Dajoku
  class YamlFetcher
    attr_reader :file_name, :timestamp, :created_at, :yaml

    def initialize(env, options = {})
      @environment = env
    end

    def self.call(env, options = {})
      new(env).fetch_yaml(**options)
    end

    def fetch_yaml(force_fetch: false, delete_file: false, ttl: Settings::DJALL.yaml.ttl)
      file_name = extant_yamls.sort.pop unless force_fetch
      if file_name.nil? || expired?(file_name, ttl)
        file_name = fetch_remote_yaml
      end
      @file_name = file_name
      yaml_deets(file_name) unless file_name.nil?
      self
    ensure
      delete_expired
    end

    def expired?(file_name, ttl = Settings::DJALL.yaml.ttl)
      time = yaml_date(file_name)
      time.to_i + ttl < Time.now.to_i
    end

    def extant_yamls(env = nil)
      env ||= @environment
      Dir.glob("#{Settings::DJALL.yaml.default_folder}/#{yaml_key(env)}")
    end

    def variables
      (@yaml['secrets'] + @yaml['configs']).map {|v| Dajoku::Variable.new(v['name'], v, @environment) }
    end

    private

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

      def fetch_remote_yaml
        file_name = nil
        password = Settings::DJALL.secret_password
        env = @environment
        command = "DAJOKU_SKIP_UPDATE=true dajoku env export -s #{env.space} -e #{env.name} -a #{env.application} -r #{env.region} #{password ? '--' : '' }#{password} 2>&1"
        stdout = `#{command}`
        if $?.exitstatus.zero?
          re = /filepath\:\s*(.*)$/
          matched = stdout.match(re)
          if matched
            file_name = matched[1]
          end
        end
        file_name
      end

      def delete_expired
        files = Dir.glob("#{Settings::DJALL.yaml.default_folder}/#{yaml_key(@environment)}")
        files.each do |file|
          try_delete_file(file) if expired?(file)
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
