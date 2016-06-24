$:.unshift File.join(File.dirname(__FILE__))

require 'rubygems'
require 'bundler/setup'
require 'dotenv'

require 'lib/ip_retriever'

Dotenv.load

puts IpRetriever.new.ip_list.size
