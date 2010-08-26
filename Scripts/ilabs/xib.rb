
module ILabs; end

module ILabs::XIB
	IB = "com.apple.ibtool"
	IBDOC = "com.apple.ibtool.document"
	
	DEBUG = ENV['ILABS_DEBUG'] == "YES"
	def self.log(x)
		$stderr.puts x if DEBUG
	end
	
	class XIBDocument		
		def initialize(hash)
			@hash = hash
			@objects = {}
		end
	
		def [](id)
			@objects[id] = XIBObject.new(self, id) unless @objects[id]
			
			@objects[id]
		end
	
		def file_owner
			object_for_proxy_identifier :IBFilesOwner
		end
	
		def object_for_proxy_identifier(proxy_id)
			proxy_id = proxy_id.to_s
		
			@hash["#{IBDOC}.objects"].each do |id, obj|
				return self[id] if obj['proxiedObjectIdentifier'] == proxy_id
			end
		
			nil
		end
	
		def objects_of_class(class_name)
			class_name = class_name.to_s
			x = []
		
			@hash["#{IBDOC}.objects"].each do |id, obj|
				x << self[id] if obj['custom-class'] == class_name or obj['class'] == "IB#{class_name}"
			end
		
			x
		end
		
		def root_objects
			x = []
		
			@hash["#{IBDOC}.hierarchy"].each do |root_obj|
				x << self[root_obj['object-id']]
			end
		
			x
		end
		
		def objects
			x = []
			@hash["#{IBDOC}.objects"].each do |id, obj|
				x << self[id]
			end
			
			x
		end
	
		# Hash [ name => object id ]
		def connections_from(oid)
			x = {}
			@hash["#{IBDOC}.connections"].each do |id, conn|
				if conn['source-id'].to_i == oid.to_i
					x[conn['label']] = self[conn['destination-id']]
				end
			end
		
			x
		end
	
		def kind_of_object(oid)
			custom = @hash["#{IBDOC}.objects"][oid.to_s]['custom-class']
			return custom if custom
		
			class_name = @hash["#{IBDOC}.objects"][oid.to_s]['class']
			if class_name.start_with? "IB"
				class_name = class_name[2, class_name.length - 2]
			end
		
			return class_name
		end
	
		def localizable_properties_of_object(oid)
			@hash["#{IBDOC}.localizable-all"][oid.to_s] || {}
		end
	
		def children_of_object(oid)
			ILabs::XIB::log " -- Looking for children of #{oid}"
			x = nil
			@hash["#{IBDOC}.hierarchy"].each do |root_object|
				x = _get_children_of_oid(root_object, oid)
				break if x
			end
		
			result = []
			x.each do |entry|
				result << self[entry['object-id']]
			end
		
			return result
		end
	
		def _get_children_of_oid(node, oid)
			ILabs::XIB::log " -- Looking in node #{node.inspect}"
			if node['object-id'].to_i == oid.to_i
				ILabs::XIB::log " -- Node with oid #{oid} found with children #{node['chilren'].inspect}"
				return node['children'] || []
			elsif node['children']
				node['children'].each do |child|
					ILabs::XIB::log " --> Moving into #{child.inspect}"
					x = _get_children_of_oid(child, oid)
					return x if x
				end
			end
		
			return nil
		end
	
		def class_inherits_from(class_name, parent_name)
			return true if class_name == parent_name
		
			class_def = @hash["#{IBDOC}.classes"][class_name]
			while class_def and class_def['superclass']
				return true if class_def['superclass'] == parent_name
				class_def = @hash["#{IBDOC}.classes"][class_def['superclass']]
			end
		
			return false
		end
	end

	class XIBObject
		def initialize(xib, id)
			@xib = xib; @id = id
		end
	
		def connections
			@xib.connections_from(@id)
		end
	
		def kind
			@xib.kind_of_object(@id)
		end
	
		def inspect
			"#<#{self.class} [object id #{@id} (#{self.kind})]>"
		end
	
		def localizable_properties
			@xib.localizable_properties_of_object(@id)
		end
	
		def children
			@xib.children_of_object(@id)
		end
	
		def class_inherits_from(parent_name)
			@xib.class_inherits_from(kind, parent_name)
		end
	
		attr_reader :xib, :id
	end
end
