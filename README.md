# dj-all
Interrogatin' the dajokuspace

---
## About _dajento_
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
## Available Commands

### DjAll
Download, merge, and compare multiple environemts and creat a best-guess environment dajoku configuration from the comparison oft he included environments

In development, run from the command-line
```
$ bin/dj-all -a greenhouse -e 'prod,prod,use1|prod,prod-s2,use1' -v *SOLR*
```
If it has been installed using `gem install` then simply run
```
dj-all ...
```
