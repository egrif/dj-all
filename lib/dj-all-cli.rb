#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'dj-all/controller'
require 'settings/dj-all'
require 'dj-all/version'
require 'optparse'
require 'ostruct'

def valid_application?(application)
  !application.nil? && !application.empty?
end

def valid_environments?(environments)
  !environments.any?{|e| e.count != 3}
end

def environments_parser(env_string, options)
  envs = env_string.split(Settings::DJALL.cli.delimiters.envs)
  envs.map do |env|
    deets = env.split(Settings::DJALL.cli.delimiters.env_deets)
    case deets.count
    when 0
      raise OptionParser::InvalidArgument.new("Invalid Environment [#{env}] in environments string [#{env_string}]: No parts defined")
    when 1
      puts options
      if options.space && options.region
        deets.unshift(options.space) << options.region
      else
        raise OptionParser::InvalidArgument.new("Invalid Environment [#{env}] in environments string [#{env_string}]: Not enough parts defined")
      end
    when 2
      if options.space && !options.region
        deets.unshift(options.space)
      elsif options.region && ! options.space
        deets << options.region
      else
        raise OptionParser::InvalidArgument.new("Invalid Environment [#{env}] in environments string [#{env_string}]: ambiguous environment definition")
      end
    when 3
      deets[0] = options.space if deets[0].strip.empty? && options.space
      deets[2] = options.region if deets[2].strip.empty? && options.region
    else
      raise OptionParser::InvalidArgument.new("Invalid Environment [#{env}] in environments string [#{env_string}]: Too many parts")
    end
    deets
  end
end

env_delim = Settings::DJALL.cli.delimiters.envs
deets_delim = Settings::DJALL.cli.delimiters.env_deets
params = OpenStruct.new
parser = OptionParser.new do |opts|
  opts.banner = "Usage: dj_all -a DAJOKU_APPLICATION_NAME -e SPACE#{deets_delim}NAME#{deets_delim}REGION#{env_delim}SPACE#{deets_delim}NAME#{deets_delim}REGION#{env_delim}... -v VARIABLE_NAME"
  opts.separator ""

  opts.on('-a', '--application APPLICATION', "(REQUIRED) Dajoku application name") do |app|
    params.application = app
  end

  opts.on('-g', '--group GROUP_NAME', '(Optional) environment group name') do |group|
    raise "Default groups not found for application [#{params.application}]" if Settings::DJALL.groups[params.application].nil?
    raise "Default group [#{group}] not found for application [#{params.application}]" if Settings::DJALL.groups[params.application][group].nil?
    params.environments = Settings::DJALL.groups[params.application][group].split("|").map{|env| env.split(",")}
  end

  opts.on('-s', '--space DEFAULT_SPACE', "(Optional) Default space for any environment with undefined SPACE (ignored if -g specified)") do |space|
    if params.environments.nil?
      params.space = space
    else
      puts "-s (DEFAULT_SPACE) ignored in favor of -g (group)"
    end
  end

  opts.on('-r', '--region DEFAULT_REGION', "(Optional) Default region for any environment with undefined REGION (ignored if -g specified)") do |region|
    if params.environments.nil?
      params.region = region
    else
      puts "-r (DEFAULT_REGION) ignored in favor of -g (group)"
    end
  end

  opts.on('-e', '--environments ENVIRONMENTS', "(Optional) '|'-separated 'SPACE,NAME,REGION' coordinates of dajoku environments to compare") do |envs_string|
    if params.environments.nil?
      params.environments = environments_parser(envs_string, params)
    else
      puts "-e (environments) ignored in favor of -g (group)"
    end
  end

  opts.on('-v', '--variable VARIABLE_NAME ', "(REQUIRED) comma-separated list of names of environment variables to show, wildcards allowed") do |var|
    params.variable_name = var.split(',')
  end

  opts.on('-f', '--force-fetch', "(Optional) Ignore the yaml ttl and fetch all environments") do |var|
    params.force_fetch = true
  end

  opts.on('-t', '--spreadsheet-formatting', '(Optional) format for easy spreadsheet parsing (same constant between every colum).  Pass a delimiter string or 3 spaces will be defaulted') do |ss|
    params.spreadsheet_formatting = (ss.respond_to?(:length) ? ss : "   ")
  end

  opts.on('-p', '--pivot', '(Optional) Put variable names across the top and environments down the side of the output table') do |pivot|
    params.pivot = pivot
  end

  opts.on('--debug','debug on') do |bool|
    params.debug = true
  end

  opts.on('--version','show version') do |v|
    puts
    puts "dj_all v#{DjAll::VERSION}"
    puts
  end
end.parse!

puts params if params[:debug]

unless params[:application] && params[:environments]
  puts parser
  exit
end

raise OptionParser::InvalidArgument.new("You must specify a valid dajoku application") unless valid_application?(params[:application])
raise OptionParser::InvalidArgument.new("Procedure requires at least 2 Environments in the form 'SPACE,NAME,REGION|SPACE,NAME,REGION|...'") unless valid_environments?(params[:environments])
raise OptionParser::InvalidArgument.new("Procedure requires a variable name") if params[:variable_name].nil?

DjAll::Controller.new_from_params(params[:application], params[:environments]).show_vars(
  params[:variable_name],
  force_fetch: params.force_fetch,
  spreadsheet_formatiing: params.spreadsheet_formatting,
  pivot: params.pivot
)
