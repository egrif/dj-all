# dj-all
Interrogatin' the dajokuspace

---
## About _dajento_
This is a collection of command-line executables to help with examining and comparing dajoku values in multiple-environment settings
## Installation
Tese command line tools can be installed by running
```
gem install dajoku-environment-tools
```
HOWEVER, your `~/.gemrc` will need to have the following lines in it:
```
:sources:
- https://rubygems.org/
- https://USERNAME:TOKEN@rubygems.pkg.github.com/grnhse/
:update_sources: true
:verbose: true
```
where
 - USERNAME is your github user id
 - TOKEN is a personal access token that with `read:packages` privileges
## Available Commands

### Juxtaconfig
Download, merge, and compare multiple environemts and creat a best-guess environment dajoku configuration from the comparison oft he included environments

In development, run from the command-line
```
$ bin/juxtaconfig -a greenhouse -e prod,prod,use1|prod,prod-s2,use1'
```
If it has been installed using `gem install` then simply run
```
juxtaconfig ...
```
### DjAll
output to the console values in all specified environmants for a specified variable

In development, run from the command-line
```
$ bin/dj-all -a greenhouse -d us -v *SOLR*
```
If it has been installed using `gem install` then simply run
```
dj-all ...
```

## Contributing
Submit a PR and ping #runfast
### Adding a New Executable
- Create a folder in the repo root named the same as your executable
- Create the CLI tool in this folder, with the name of the executable
- Copy one of the files in `/bin` to a new file with the executable name
- Edit the copied file to refer to your new tool
- Add the executable name to the `/dajoku-environment-tools.gemspec` s.executables array

You should be able to run your executable with the command
```
bin/<EXECUTABLE_NAME>
```
NOTE: Before pushing, increment the version number (semantic versioning) otherwise the github workflow will not be able to build a new release
