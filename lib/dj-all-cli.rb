#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'dj-all/controller'
require 'settings/dj-all'
require 'dj-all/version'
require 'optparse'
require 'ostruct'

#TODO: Refactor this for reusablility (dajoku tools) and readability
class DjAllCli

  def self.valid_application?(application)
    !application.nil? && !application.empty?
  end

  def self.valid_environments?(environments)
    !environments.any?{|e| e.count != 3}
  end

  def self.environments_parser(env_string, options)
    envs = env_string.split(Settings::DJALL.cli.delimiters.envs)
    envs.map do |env|
      deets = env.split(Settings::DJALL.cli.delimiters.env_deets)
      case deets.count
      when 0
        abort("ERROR: Invalid Environment [#{env}] in environments string [#{env_string}]: No parts defined")
      when 1
        if options.space && options.region
          deets.unshift(options.space) << options.region
        else
          abort("ERROR: Invalid Environment [#{env}] in environments string [#{env_string}]: Not enough parts defined")
        end
      when 2
        if options.space && !options.region
          deets.unshift(options.space)
        elsif options.region && ! options.space
          deets << options.region
        else
          abort("ERROR: Invalid Environment [#{env}] in environments string [#{env_string}]: ambiguous environment definition")
        end
      when 3
        deets[0] = options.space if deets[0].strip.empty? && options.space
        deets[2] = options.region if deets[2].strip.empty? && options.region
      else
        abort("ERROR: Invalid Environment [#{env}] in environments string [#{env_string}]: Too many parts")
      end
      deets
    end
  end

  def self.call
    env_delim = Settings::DJALL.cli.delimiters.envs
    deets_delim = Settings::DJALL.cli.delimiters.env_deets
    params = OpenStruct.new
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: dj_all -a DAJOKU_APPLICATION_NAME -e SPACE#{deets_delim}NAME#{deets_delim}REGION#{env_delim}SPACE#{deets_delim}NAME#{deets_delim}REGION#{env_delim}... -v VARIABLE_NAME [options]"
      opts.separator ""

      opts.on('-a', '--application APPLICATION', "(REQUIRED) Dajoku application name") do |app|
        params.application = app
      end

      opts.on('-g', '--group GROUP_NAME', 'environment group name') do |group|
        params.group = group
      end

      opts.on('-s', '--space DEFAULT_SPACE', "Default space for any environment with undefined SPACE (ignored if -g specified)") do |space|
        params.space = space
      end

      opts.on('-r', '--region DEFAULT_REGION', "Default region for any environment with undefined REGION (ignored if -g specified)") do |region|
        if params.environments.nil?
          params.region = region
        else
          puts "INFO: -r (DEFAULT_REGION) potentially ignored in favor of -g (group)"
        end
      end

      opts.on('-e', '--environments ENVIRONMENTS', "'#{env_delim}'-separated 'SPACE#{deets_delim}NAME#{deets_delim}REGION' coordinates of dajoku environments to compare") do |envs_string|
        params.environment_string = envs_string
      end

      opts.on('-v', '--variable VARIABLE_NAME ', "(REQUIRED) comma-separated list of names of environment variables to show, wildcards allowed") do |var|
        params.variable_name = var.split(',')
      end

      opts.on('-f', '--force-fetch', "Ignore the yaml ttl and fetch all environments") do |var|
        params.force_fetch = true
      end

      opts.on('-t', '--spreadsheet', "format for easy spreadsheet parsing (\"#{Settings::DJALL.formatting.default_spreadsheet_delimiter}\" between every column).") do |ss|
        params.spreadsheet_formatting = Settings::DJALL.formatting.default_spreadsheet_delimiter
      end

      opts.on('-u', '--spreadsheet-delimiter Delimiter', 'format for easy spreadsheet parsing. Pass a column-delimiter string') do |ss|
        params.spreadsheet_formatting = ss
      end

      opts.on('-p', '--pivot', 'Put variable names across the top and environments down the side of the output table') do |pivot|
        params.pivot = pivot
      end

      opts.on('-x', '--expose-secrets', 'Show secrets in output (only if DJ_ALL_SECRET_PASSWORD is set)') do |expose|
        params.expose_secrets = expose
      end

      opts.on('--debug','debug on') do |bool|
        params.debug = true
      end

      opts.on('--version','show version') do |v|
        puts
        puts "dj_all v#{DjAll::VERSION}"
        puts
      end
    end

    commands = parser.parse!

    if commands.include?('groups') # show group definitions then exit
      abort "ERROR: Default groups not found for application [#{params.application}]" if params.application.nil? || Settings::DJALL.groups[params.application].nil?
      groups = Settings::DJALL.groups[params.application]
      puts "Defined Groups:"
      puts ""
      max_length = groups.each_pair.map {|k,v| k }.reduce(0) {|max,name| name.length > max ? name.length : max }
      groups.each_pair do |name,envs|
        env_names = envs.split(Settings::DJALL.cli.delimiters.envs).map {|deet| deet.split(Settings::DJALL.cli.delimiters.env_deets)[1]}.sort.join(', ')
        puts "#{" "*(max_length - name.length)}#{name.to_s}  #{env_names}"
      end
      exit
    end

    if params.debug
      puts params
      puts ''
    end

    # defaults
    unless params.application
      abort "ERROR: Default groups not found for application [#{params.application}]" if params.application.nil? || Settings::DJALL.groups[params.application].nil?
      params.environments = environments_parser(Settings::DJALL.groups[params.application], params)
    end

     # validation and processing
    if params.group && params.space
      puts "INFO: -s (DEFAULT_SPACE) potentially ignored in favor of -g (group)"
    end

    if params.group && params.region
      puts "INFO: -r (DEFAULT_REGION) potentially ignored in favor of -g (group)"
    end

    if params.environment_string && params.group
      puts "INFO: -e (environments) ignored in favor of -g (group)"
    end

    if params.group
      abort "ERROR: Default groups not found for application [#{params.application}]" if params.application.nil? || Settings::DJALL.groups[params.application].nil?
      abort "ERROR: Default group [#{params.group}] not found for application [#{params.application}]" if Settings::DJALL.groups[params.application][params.group].nil?
      params.environments = environments_parser(Settings::DJALL.groups[params.application][params.group], params)
    elsif params.environment_string
      params.environments = environments_parser(params.environment_string, params)
    end

    unless params.application && params.environments
      puts parser
      exit
    end

    abort "ERROR: You must specify a valid dajoku application (-a)" unless valid_application?(params[:application])
    abort "ERROR: Procedure requires a variable name (-v)" if params[:variable_name].nil?

    DjAll::Controller.new_from_params(params[:application], params[:environments]).show_vars(
      params[:variable_name],
      force_fetch: params.force_fetch,
      spreadsheet_formatting: params.spreadsheet_formatting,
      pivot: params.pivot,
      expose_secrets: params.expose_secrets
    )
  end

end

DjAllCli.call
