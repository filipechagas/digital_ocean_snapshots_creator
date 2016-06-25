$:.unshift File.join(File.dirname(__FILE__))

require 'rubygems'
require 'bundler/setup'
require 'dotenv'
require 'awesome_print'

require 'lib/snapshots_monitor'

Dotenv.load

ap SnapshotsMonitor.new.perform.count
