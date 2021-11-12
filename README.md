# dj-all
Interrogatin' the dajokuspace

---
## About _dj-all_
This is a collection of command-line executables to help with examining and comparing dajoku values in multiple-environment settings
## Installation
These command line tools can be installed by running
```
gem install dj-all
```
HOWEVER, your `~/.gemrc` will need to have the following lines in it:
```
:sources:
- https://rubygems.org/
- https://USERNAME:TOKEN@rubygems.pkg.github.com/egrif/
:update_sources: true
:verbose: true
```
where
 - USERNAME is your github user id
 - TOKEN is a personal access token that with `read:packages` privileges

 ### Dependencies
 This is a wrapper around the inimitable `dajoku` cli, therefore, you must have that installed and you must have proper permissions to run that in order for `dj-all` to have any power in this (ie, your specific) universe
## Available Commands

### dj-all
Download, merge, and compare multiple environemts and creat a best-guess environment dajoku configuration from the comparison oft he included environments

In development, run from the command-line
```
$ bin/dj-all -a greenhouse -e 'prod,prod,use1|prod,prod-s2,use1' -v *SOLR*
```
If it has been installed using `gem install` then simply run
```
dj-all ...
```
#### Usage
```
Usage: dj_all -a DAJOKU_APPLICATION_NAME -e SPACE,NAME,REGION:SPACE,NAME,REGION:... -v VARIABLE_NAME

    -a, --application APPLICATION    (REQUIRED) Dajoku application name
    -g, --group GROUP_NAME           (Optional) environment group name
    -s, --space DEFAULT_SPACE        (Optional) Default space for any environment with undefined SPACE (ignored if -g specified)
    -r, --region DEFAULT_REGION      (Optional) Default region for any environment with undefined REGION (ignored if -g specified)
    -e, --environments ENVIRONMENTS  (Optional) '|'-separated 'SPACE,NAME,REGION' coordinates of dajoku environments to compare
    -v, --variable VARIABLE_NAME     (REQUIRED) comma-separated list of names of environment variables to show, wildcards allowed
    -f, --force-fetch                (Optional) Ignore the yaml ttl and fetch all environments
    -t, --spreadsheet-formatting     (Optional) format for easy spreadsheet parsing (same constant between every colum).  Pass a delimiter string or 3 spaces will be defaulted
    -p, --pivot                      (Optional) Put variable names across the top and environments down the side of the output table
        --debug                      debug on
        --version                    show version
```
Like so:
```
dj-all -a greenhouse -s prod -r use1 -e prod:prod-base:canary -v *SOLR*
```
#### Configuration
A configuratiuon yaml file lives in `lib/settings/dj-all.yml`.  You can override any setting in there (or add to the available environemnt groups by application) by creating a yaml file at `~/.dj-all.yml` and overriding (or adding) the keys you need.

If you want your yaml file in a different location, that works too if you set and environment variable pointing to the location of your configuration
`export DJALL_CONFIG_FILE=<full path to your config file>`.  WARNING: we don't do any error checking on the config file, so this is a great way to break things, if that is your inclination.

Another environment variable you can set is `DJ_ALL_SECRET_PASSWORD` (yes, that's a different convention.  So sue me).  If you set this to the value of the password that tells dajoku to unencrypt the secrets, this will give you the plain text values of any secrets you pull

## DST
OMG, I just realized that if you are running this between 1 am and 2 am (second time) on the morning the clock gets set back for DST, you might have a problem getting the yaml data to refresh, since the expiration strategy will be confuzzled by the time change.  Don't worry, though, when you finally reach 2:00:01 am, everything should start working fine.  (Also, I _think_ that using the `-f` flag should force a refresh even in that situation).

We, here at DjAll-central, strongly recommend that the best way to avoid this problem is by not using this tool (nor any other, honestly) between 1 and 2 am on mornings that the time is likely to change.
