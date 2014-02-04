#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'optparse'

options = {}

optparse = OptionParser.new do |opts|
	opts.banner = "Usage: check_hdfs.rb [options]"
 	opts.on("-u", "--url URL", "URL of ") do |url|
 		options[:url] = url
 	end
	opts.on("-w", "--warningnumtts WARNINGNUMTTS", "Warning Limit for number of TTs") do |warningtts|
		options[:warningtts] = warningtts
	end
	opts.on("-c", "--criticaltts CRITICALTTS", "Critical Limit for number of TTs") do |criticaltts|
		options[:criticaltts] = criticaltts
	end
	opts.on("-H", "--help", "Display this screen") do
    puts opts
    exit
  end
end

optparse.parse!

url = options[:url]
warningtts = options[:warningtts]
criticaltts = options[:criticaltts]

page = Nokogiri::HTML(open("#{url}"))
page.css('table.datatable tr td[2]').each do |el|
   puts el.text
end
