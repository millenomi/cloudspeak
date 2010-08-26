require 'ilabs/xib'
require 'ilabs/ibtool'
require 'ilabs/cloudspeak'
include ILabs::XIB

require 'rubygems'
require 'optparse'
require 'json'

def log x
	ILabs::XIB.log x
end

def main
	root_class_name = nil
	file = nil
	
	format = :json
	
	OptionParser.new do |o|
		o.banner = "Usage: #{$0} --input=FILE [OPTIONS]"
		
		o.on("-i", "--input [FILE]", "The XIB file to use as input") do |f|
			file = f
		end

		o.on("-c", "--class [CLASS]", "Use object of the specified class instead of using File's Owner as the root for key paths") do |cls|
			root_class_name = cls
		end
		
		o.on("-f", "--format [json|plist|keyset]", "Set what format to use for output. Defaults to 'json'. 'keyset' outputs a NSSet initialization suitable to be returned by a -localizableKeyPaths override in a UIViewController") do |f|
			format = f.to_sym
		end
	end.parse!
	
	xib = XIBDocument.from_file(file)
	if root_class_name
		roots = xib.objects_of_class(root_class_name)
		raise "Can't find exactly one object of class #{root_class_name}! -- maybe there's none, or there's more than one." unless roots.length == 1
		root = roots[0]
	else
		root = xib.object_for_proxy_identifier :IBFilesOwner 
	end
	
	paths = ILabs::Cloudspeak.localizable_key_paths_for_object(root)
	
	case format
	when :json
		JSON.dump(paths)
	when :plist
		puts OSX.object_to_plist(paths)
	when :keyset
		s = "[NSSet setWithObjects:\n"
		paths.each_key do |k|
			s << "\t@\"#{k}\",\n"
		end
		s << "\tnil];"
		puts s
	else
		raise "Unknown format: #{format}"
	end
end

# go!
main
