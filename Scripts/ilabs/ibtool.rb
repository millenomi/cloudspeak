
require 'ilabs/xib'
require 'osx/cocoa'

module ILabs; end

module ILabs::IBTool	
	def self.hash_from_xib_file(file)
		str = nil
		IO.popen('-') do |input|
			Process.exec '/usr/bin/ibtool', '--all', file unless input
			str = input.read
		end
		
		OSX.load_plist(str)
	end
end

module ILabs::XIB
	class XIBDocument
		def self.from_file(file)
			hash = ILabs::IBTool.hash_from_xib_file(file)
			XIBDocument.new(hash)
		end
	end
end
