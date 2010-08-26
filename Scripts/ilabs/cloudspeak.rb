
require 'set'

module ILabs; end

module ILabs::Cloudspeak
	class LocalizableKeyPathsFinder
		def initialize
			@exception_keys = Set.new
			@children_keys = {}
			@exception_objects = Set.new
			@replacement_keys = {}
		end
		
		def except_key k
			@exception_keys << k
		end
		
		def except_object o
			@exception_objects << o
		end
		
		def except_all_object os
			os.each { |o| except_object o }
		end
		
		def children_key class_name, child_class_name, key
			@children_keys[class_name] = {} unless @children_keys[class_name]
			@children_keys[class_name][key] = child_class_name
		end
		
		def replacement_key class_name, original_key, replacement
			@replacement_keys[class_name] = {} unless @replacement_keys[class_name]
			@replacement_keys[class_name][original_key] = replacement
		end
		
		def search(o)
			
		end
		
		def subsearch(o, encountered)
			return nil if encountered.include? o
			encountered << o
			
			kind = o.kind
			
			locprops = {}
			o.localizable_properties.each do |name, value|
				name = actual_name_for_key(o, name)
				next if is_exception_key? name
				
				locprops[name] = value
			end
			
			@children_keys.each_key do |class_name, entries|
				if xo.class_inherits_from(class_name)
					
					xo.children.each do |c|
						entries.each do |key, child_class_name|
							key = actual_name_for_key(c, key)
							next if is_exception_key? key
							
							if c.class_inherits_from(child_class_name)
								paths = subsearch(c, encountered)
								next unless paths
								
								paths.each do |path, value|
									locprops["#{key}.#{path}"] = value
								end
							end
						end
						
					end
					
				end
			end
			
		end
		
		def is_exception_key? k
			@exception_keys.include? k
		end
		
		def actual_name_for_key(o, key)
			@replacement_keys.each do |class_name, entries|
				if entries[key] and o.class_inherits_from(class_name)
					return entries[key]
				end
			end
			
			key
		end
	end
	
	def self.localizable_key_paths_for_object(xo, seen_object_ids = [])
		return {} if seen_object_ids.include? xo.id
		seen_object_ids << xo.id

		log "Inspecting #{xo.inspect}"
		paths = xo.localizable_properties
		log "Found loc properties #{paths.inspect}"

		paths.delete "frameSize"
		paths.delete "frameOrigin"
		paths.delete "autoresizingMask"
		paths.delete "width"
		paths.delete "baselineAdjustment"
		paths.delete "textAlignment"
		paths.delete "contentHorizontalAlignment"
		paths.delete "contentVerticalAlignment"

		xo.connections.each do |name, xo2|
			log "Inspecting connection #{name} leading to #{xo2.inspect}"
			localizable_key_paths_for_object(xo2, seen_object_ids).each do |lockp, value|			
				if xo2.class_inherits_from 'UIButton' and lockp == 'normalTitle'
					lockp = 'localizableNormalTitle'
				end

				paths["#{name}.#{lockp}"] = value
			end		
		end

		if xo.class_inherits_from('UIViewController')
			xo.children.each do |child|
				if child.kind == 'UITabBarItem'
					localizable_key_paths_for_object(child, seen_object_ids).each do |lockp, value|
						paths["tabBarItem.#{lockp}"] = value
					end
				elsif child.kind == 'UINavigationItem'
					localizable_key_paths_for_object(child, seen_object_ids).each do |lockp, value|
						paths["navigationItem.#{lockp}"] = value
					end
				elsif child.class_inherits_from('UIView')
					localizable_key_paths_for_object(child, seen_object_ids).each do |lockp, value|
						paths["view.#{lockp}"] = value
					end
				end
			end
		end

		paths
	end
	
end