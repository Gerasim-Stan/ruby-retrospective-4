module RBFS
  class RBFS::File
    attr_reader :data_type, :data

    def init_data_type
      @data_type = case @data
                     when NilClass              then @data_type = :nil
                     when String                then @data_type = :string
                     when Symbol                then @data_type = :symbol
                     when Numeric               then @data_type = :number
                     when TrueClass, FalseClass then @data_type = :boolean
                   end
    end

    def initialize(data = nil, data_type = nil)
      @data = data
      if data_type.nil?
        init_data_type
      else
        @data_type = data_type
      end
    end

    def data=(data)
      @data = data
      init_data_type
    end

    def serialize
      "#{@data_type}:#{@data.to_s}"
    end

    def self.parse(file_data)
      case file_data.split(':', 2)[0]
        when 'nil'     then File.new nil
        when 'string'  then File.new file_data.split(':', 2)[1]
        when 'symbol'  then File.new file_data.split(':', 2)[1].to_sym
        when 'number'  then File.new file_data.split(':', 2)[1].to_f
        when 'boolean' then File.new file_data.split(':', 2)[1] == 'true'
      end
    end
  end

  class RBFS::Directory
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
      @directories[name].nil? ? @files[name] : @directories[name]
    end

    def serialize_files_or_directories(object)
      object.map do|object_name, object_content|
        serialized_object = object_content.serialize
        "#{object_name}:#{serialized_object.length}:#{serialized_object}"
      end
      .join
    end

    def serialize
    "#{@files.size}:#{serialize_files_or_directories @files}" \
    "#{@directories.size}:#{serialize_files_or_directories @directories}"
    end

    def self.parse_files_or_directories(dir_data, type)
      data, slash = {}, dir_data.split(':', 2)
      1.upto(slash[0].to_i) do
        slash[2] = slash[1].split(':', 3)
        data[slash[2][0]] = type.new(slash[2][2].slice(0, slash[2][1].to_i)
        .split(':')[1], slash[2][2].split(':')[0].to_sym)
        slash[1] = slash[2][2].slice(slash[2][1].to_i, slash[2][2].length)
      end
      data[slash[2][0]] = parse(slash[2][2]) unless type != Directory or slash[2].nil?
      [data, slash[1]]
    end

    def self.parse(dir_data)
      directories, files = {}, {}
      files, dir_data = parse_files_or_directories(dir_data, File)
      directories, dir_data = parse_files_or_directories(dir_data, Directory)
      directory = Directory.new directories, files
    end
  end
end

