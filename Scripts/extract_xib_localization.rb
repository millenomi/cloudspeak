require 'ilabs/xib'
require 'ilabs/ibtool'
require 'ilabs/cloudspeak'
include ILabs::XIB

require 'rubygems'
require 'optparse'
require 'osx/cocoa'
require 'json'

def log x
	ILabs::XIB.log x
end

def main
	root_class_name = nil
	file = nil
	
	OptionParser.new do |o|
		o.banner = "Usage: #{$0} --input=FILE [OPTIONS]"
		
		o.on("-i", "--input [FILE]", "The XIB file to use as input") do |f|
			file = f
		end
	end.parse!
	
	xib = XIBDocument.from_file(file)
	
	tables = {}
	
	xib.objects.each do |o|
		paths = ILabs::Cloudspeak.localizable_key_paths_for_object(o)
		unless paths.empty?
			tables[o.kind] = paths
		end
	end	
	
	puts OSX.object_to_plist(tables)
end

# go!
main
