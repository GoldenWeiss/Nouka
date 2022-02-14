module MIRMarshal
	MARSHAL_MAJOR = 4
	MARSHAL_MINOR = 8
	
	class << self
		@@constantsCache = {}
		attr_reader :data
		
		# Loader
		def load(data)
			@symbolsCache 	= []
			@objectsCache 	= []
			@errorMessage 	= ""
			@data = data.chars
			major, minor = readByte, readByte
			if (MARSHAL_MAJOR != major) or (MARSHAL_MINOR > minor)
				setErrorMessage("Invalid Marshal Header.\n" + 
				"Expected : [#{MARSHAL_MAJOR}, #{MARSHAL_MINOR}]. Got : [#{major}, #{minor}].")
				return
			end
			return read 
		end
		def readChar
			return @data.shift
		end
		def readByte
			return readChar.ord
		end
		def read
			character = readChar
			case character
			when '0' then return nil
			when 'T' then return true
			when 'F' then return false
			when 'i' then return readInteger
			when 'l' then return readBignum
			when ':' then return readSymbol
			when 'I' then return read
			when '"' then return readString
			when '[' then return readArray
			when '{' then return readHash
			when 'f' then return readFloat
			when 'c' then return readClass
			when 'm' then return readModule
			when 'M' then return readModuleOrClass
			when 'S' then return readStruct
			when '/' then return readRegexp
			when 'o' then return readObject
			when 'e' then return readExtendedObject
			when 'C' then return readUserClass
			when ';' then return readSymbolLink
			when '@' then return readObjectLink
			when 'u' then return readUserDefined
			when 'U' then return readUserMarshal
			else
			
				setErrorMessage("Unknow Object Byte Header[#{character.ord}]")
				return
			end
		end
		["symbol", "object"].each { |type|
			class_eval(<<-EOF
			def cache#{type.capitalize}(obj)
				@#{type}sCache << obj
				return obj
			end
			def read#{type.capitalize}Link
				return @#{type}sCache[readInteger]
			end
			EOF
			)
		}
		def cacheConstant(obj)
			s = obj.to_s
			@@constantsCache[s] = [] if @@constantsCache[s] == nil
			@@constantsCache[s] << $loadingFile
			return obj
		end

		def readInteger
			byteHeader = ((readByte ^ 128) - 128)
			case byteHeader
			when 0        then return 0
			when 4..127   then return byteHeader - 5
			when 1..3     then return byteHeader.times.map { |i| [i, readByte]}.inject(0) { |result, (i, byte)| result | (byte << (8*i))  }
			when -128..-6 then return byteHeader + 5
			when (-5..-1)
			 return (-byteHeader).
				times.
				map { |i| [i, readByte] }.
					inject(-1) do |result, (i, byte)|
						a = ~(0xff << (8*i))
						b = byte << (8*i)
						(result & a) | b
					end
			else
				setErrorMessage("Invalid Integer Byte Header [#{byteHeader}].")
				return
			end
		end
		
		def readSymbol
			e = String.new
			readInteger.times { e += readChar }
			return cacheSymbol ( e.to_sym )
		end
		def readString
			e = String.new
			readInteger.times { e += readChar }
			return cacheObject ( e )
		end
		def readArray
			return cacheObject ( Array.new(readInteger) { read } )
		end
		def readHash
			return cacheObject ( Hash[Array.new(readInteger) { [read, read] } ] )
		end
		def readFloat
			e = readString
			if (/\A[-+]?\d+\z/=~e)
				v = e.to_f
			else
				case e
					when 'inf'  then v = 1.0/0.0
					when '-inf' then v = -1.0/0.0
					when 'nan'  then v = 0.0/0.0
				end
			end
			return cacheObject ( v )
		end
		["Class", "Module"].each { |type|
			class_eval (<<-EOF
			def read#{type}
				name = readString
				if Object.const_defined?(name)
					klass = Object.const_get(name)
					return cache_object ( klass ) if klass.instance_of?(#{type})
				end
				setErrorMessage("Undefined #{type} [#{name}].")
				return
			end
			EOF
			)
		}
		def readModuleOrClass
			name = readString
			return Object.const_get(name) if Object.const_defined?(name)
			setErrorMessage("Undefined Class/Module [#{name}].")
			return
		end
		def createOrGetConst(path, obj)
			unless Object.const_defined?(path)
				pathConst = path.split("::")
				nameConst = pathConst.pop
				lastConst = pathConst.inject(Object) { |ancesstor, element|
				ancesstor.const_defined?(element) ? ancesstor.const_get(element) : cacheConstant( ancesstor.const_set(element, Class.new) )} # Empty Module
				klass = cacheConstant ( lastConst.const_set(nameConst, obj) )
			else
				klass = Object.const_get(path)
			end
			return klass
		end
		def readStruct
			name = read.to_s
			data = readHash
			klass = createOrGetConst(name, Struct.new(*data.keys.map {|i| i.to_sym }))
			return cacheObject ( klass.new(*data.values) )
		end
		def readObject
			name = read.to_s
			data = readHash
			
			obj = createOrGetConst(name, Class.new).allocate
			#p data
			data.each {|n, v| obj.instance_variable_set(n, v)}
			return cacheObject ( obj )
		end
		def readExtendedObject
			mod = createOrGetConst(read.to_s, Module.new) # MyModule
			return cacheObject ( read.extend(mod) )
		end
		def readUserClass
			klass = createOrGetConst(read.to_s, Class.new)
			return cacheObject ( klass.new(read) )
		end
		def readRegexp
			return cacheObject ( Regexp.new(readString, readByte) )
		end
		def readUserDefined
			klassName = read.to_s
			objArgs = readString
			begin
				return createOrGetConst(klassName, Class.new).public_send('_load', objArgs)
			rescue Exception
				setErrorMessage("Exception Raised when loading '#{$methodFile}'.\n\n#{$!.class}\n#{$!.message}\n#{$!.backtrace}")
				return
			end
		rescue NameError
			setErrorMessage("Undefined User Defined Object.\nPlease add '_load' method to '#{klassName}' Class/Module in file :\n'#{$methodFile}'.")
			return
		end
		def readUserMarshal
			klassName = read.to_s
			objArgs = read
			begin 
				obj = createOrGetConst(klassName, Class.new).allocate
				obj.send('marshal_load', objArgs)
				return obj
			rescue Exception
				setErrorMessage("Exception Raised when loading '#{$methodFile}'.\n\n#{$!.class}\n#{$!.message}\n#{$!.backtrace}")
				return
		rescue NameError
			setErrorMessage("Undefined User Marshaled Object.\nPlease add 'marshal_load' method to '#{klassName}' Class/Module in file :\n'#{$methodFile}'.")
			return
		end
		end
		def gotError?
			return !@errorMessage.empty?
		end
		def setErrorMessage(msg)
			@errorMessage = msg
		end
		def getErrorMessage
			return @errorMessage
		end
	end
end