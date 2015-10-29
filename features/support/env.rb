require 'aruba/cucumber'
require 'stack_master'
require 'stack_master/testing'
require 'aruba/in_process'

Aruba.process = Aruba::Processes::InProcess
Aruba.process.main_class = StackMasterCLI
