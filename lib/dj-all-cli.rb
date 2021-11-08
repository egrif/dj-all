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

params = OpenStruct.new
parser = OptionParser.new do |opts|
  opts.banner = "Usage: dj_all -a DAJOKU_APPLICATION_NAME -e 'SPACE,NAME,REGION|SPACE,NAME,REGION|...' -v VARIABLE_NAME"
  opts.separator ""

  opts.on('-a', '--application APPLICATION', "(REQUIRED) Dajoku application name") do |app|
    params.application = app
  end

  opts.on('-g', '--group GROUP_NAME', '(OPTIONAL) environment group name') do |group|
    raise "Default groups not found for application [#{params.application}]" if Settings::DJALL.groups[params.application].nil?
    raise "Default group [#{group}] not found for application [#{params.application}]" if Settings::DJALL.groups[params.application][group].nil?
    params.environments = Settings::DJALL.groups[params.application][group].split("|").map{|env| env.split(",")}
  end

  opts.on('-e', '--environments ENVIRONMENTS', "(REQUIRED) '|'-separated 'SPACE,NAME,REGION' coordinates of dajoku environments to compare") do |envs_string|
    if params.environments.nil?
      params.environments = envs_string.split("|").map{|env| env.split(",")} if params.environments.nil?
    else
      puts "-e (environments) ignored in favor of -d (defaults)"
    end
  end

  opts.on('-v', '--variable VARIABLE_NAME ', "(REQUIRED) name of environment variable to show, wildcards allowed") do |var|
    params.variable_name = var.split(',')
  end

  opts.on('-f', '--force-fetch', "(Optional) Ignore the yaml ttl and fetch all environments") do |var|
    params.force_fetch = true
  end

  opts.on('--debug','debug on') do |bool|
    params.debug = true
  end

  opts.on('--version','show version') do |v|
    puts
    puts "DajokuEnvironmentTools v#{DajokuEnvironmentTools::VERSION}"
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

DjAll::Controller.new_from_params(params[:application], params[:environments]).show_vars(params[:variable_name], params.force_fetch)
