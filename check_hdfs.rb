#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'optparse'

options = {}

optparse = OptionParser.new do |opts|
	opts.banner = "Usage: check_hdfs.rb [options]"
 	opts.on("-u", "--url URL", "URL of dfs health page") do |url|
 		options[:url] = url
 	end
	opts.on("-w", "--warningdfs WARNINGDFS", "Warning Limit for DFS free space") do |warningdfs|
		options[:warningdfs] = warningdfs
	end
	opts.on("-c", "--criticaldfs CRITICALDFS", "Critical Limit for DFS free space") do |criticaldfs|
		options[:criticaldfs] = criticaldfs
	end
	opts.on("-x", "--warningunreplicatedblocks WARNINGUNREPLICATEDBLOCKS", "Warning limit for UnReplicated Blocks") do |warningunreplicatedblocks|
		options[:warningunreplicatedblocks] = warningunreplicatedblocks
	end
	opts.on("-z", "--criticalunreplicatedblocks CRITICALUNREPLICATEDBLOCKS", "Critical limit for UnReplicated Blocks") do |criticalunreplicatedblocks|
		options[:criticalunreplicatedblocks] = criticalunreplicatedblocks
	end
	opts.on("-H", "--help", "Display this screen") do
    puts opts
    exit
  end
end

optparse.parse!

url = options[:url]
warningdfs = options[:warningdfs]
criticaldfs = options[:criticaldfs]
warningunreplicatedblocks = options[:warningunreplicatedblocks]
criticalunreplicatedblocks = options[:criticalunreplicatedblocks]

to_search=['Configured Capacity','DFS Used','DFS Remaining','DFS Used%','DFS Remaining%','Number of Under-Replicated Blocks']
val_search=Array.new 
unit_val_search=Array.new

page = Nokogiri::HTML(open("#{url}"))

i=0
to_search.each do |search_str|
	key=page.search "[text()*=\'#{search_str}\']"
	keyn=key.first
	value=keyn.parent.css('td')[2].text
	val_search[i]=value.split(" ")[0].to_f
	unit_val_search[i]=value.split(" ")[1]
	i=i+1
end

if unit_val_search[0] == "GB"
	val_search[0] = val_search[0]/1000
  unit_val_search[0] = "TB"
end

if unit_val_search[1] == "GB"
	val_search[1] = val_search[1]/1000
  unit_val_search[1] = "TB"
end

if unit_val_search[2] == "GB"
	val_search[2] = val_search[2]/1000
  unit_val_search[1] = "TB"
end

#val_search.each_with_index { |val, index| puts to_search[index] + "=" + "#{val}" + unit_val_search[index].to_s }

msg = "HDFS is Ok"
returnval = 0

if val_search[4] < warningdfs.to_f
  msg = "Warning: Free space #{val_search[4]}% is less than #{warningdfs}%"
  returnval=1
end

if val_search[4] < criticaldfs.to_f
  msg = "Error: Free space #{val_search[4]}% is less than #{criticaldfs}%"
  returnval=2
end

if val_search[5] > warningunreplicatedblocks.to_f
  msg = "Warning: Under-replicated blocks are more than #{warningunreplicatedblocks}"
  returnval=1
end

if val_search[5] > criticalunreplicatedblocks.to_f
  msg = "Error: Under-replicated blocks are more than #{criticalunreplicatedblocks}"
  returnval=2
end

puts "#{msg}|capacity=#{val_search[0]} dfsused=#{val_search[1]} dfsremaining=#{val_search[2]} dfsused%=#{val_search[3]} dfsremaining%=#{val_search[4]} unreplicatedblocks=#{val_search[5]}"
exit returnval
