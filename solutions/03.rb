module RBFS
  class Parser
    def initialize(data_string)
      @data_string = data_string
    end

    def parse_list
      objects_number, @data_string = @data_string.split(':', 2)
      objects_number.to_i.times do
        object_name, object_length, object_left = @data_string.split(':', 3)
        yield object_name, object_left[0...object_length.to_i]
        @data_string = object_left[object_length.to_i..-1]
      end
    end
  end

  class File
    attr_accessor :data

    def initialize(data = nil)
      @data = data
    end

    def data_type
      case @data
        when NilClass              then :nil
        when String                then :string
        when Symbol                then :symbol
        when Numeric               then :number
        when TrueClass, FalseClass then :boolean
      end
    end

    def serialize
      "#{data_type}:#{data}"
    end

    def self.parse(file_data)
      data_type_getter, data_getter = file_data.split(':', 2)
      File.new case data_type_getter
                 when 'string'  then data_getter
                 when 'symbol'  then data_getter.to_sym
                 when 'number'  then data_getter.to_f
                 when 'boolean' then data_getter == 'true'
               end
    end
  end

  class Directory
    attr_accessor :directories, :files

    def initialize(directories = {}, files = {})
      @directories = directories
      @files = files
    end

    def add_file(name, file)
      @files[name] = file
    end

    def add_directory(name, directory = Directory.new)
      @directories[name] = directory
    end

    def [](name)
      @files[name] || @directories[name]
    end
    def serialize
      "#{serialize_list(@files)}#{serialize_list(@directories)}"
    end

    def self.parse(data_string)
      directory = Directory.new
      parser = Parser.new(data_string)
      parser.parse_list do |name, data|
        directory.add_file(name, File.parse(data))
      end
      parser.parse_list do |name, data|
        directory.add_directory(name, Directory.parse(data))
      end
      directory
    end

    private

    def serialize_list(objects)
      serialized_objects = objects.map do |name, object|
        serialized_object = object.serialize
        "#{name}:#{serialized_object.length}:#{serialized_object}"
      end
      "#{objects.count}:#{serialized_objects.join('')}"
    end
  end
end

