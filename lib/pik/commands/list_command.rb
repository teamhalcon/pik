module Pik

  class  List < Command
    
    aka :ls
    it "Lists ruby versions that pik is aware of."

    attr_reader :verbose, :remote
    
    def execute
      case @args.first
      when 'known' 
        remote_list
      when 'default'
        default_list
      else
        if remote
          remote_list
        else
         list
        end
      end
    end
    
    def remote_list
      puts Implementations.list.to_yaml
    end

    def default_list
      puts "Default Ruby\n\n"
      puts layout(config.global[:default], config[config.global[:default]])
      puts
    end
    
    def list
      config.sort.each do |name, conf|
        puts layout(name, conf)
        puts conf.map{|k,v| "        %s: %s" % [k, v]} + ["\n"] if verbose
      end
    end
    
    private
    
    def layout(name, conf)
      name = current?(conf) ? "=> #{name}" : "   #{name}"
      if name.length > columns
        remainder = -(name.length - columns + 5)
        "#{name[0,columns-5]}...#{"         ...%s" % name[remainder..-1] if verbose}"
      else
        name
      end
    end
    
    def current?(conf)
      current_path == conf[:path]
    end

    def current_path 
      @current_path ||= Which::Ruby.find
    end
    
    def columns
      @hl.output_cols
    end

    def command_options
      super
      @options.on("--verbose", "-v",
         "Verbose output"
         ) do |value|
        @verbose = value
      end
      @options.on("--remote", "-r",
         "List remote install packages"
         ) do |value|
        @remote = value
      end
    end
    
  end   
    
end