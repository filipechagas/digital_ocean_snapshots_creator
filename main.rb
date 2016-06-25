$:.unshift File.join(File.dirname(__FILE__))

require 'rubygems'
require 'bundler/setup'
require 'dotenv'
require 'awesome_print'

require 'lib/custom_logger'
require 'lib/snapshots_monitor'

Dotenv.load

SnapshotsMonitor.new.perform
