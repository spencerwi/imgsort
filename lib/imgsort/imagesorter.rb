require 'logger'
require 'json'
require 'fileutils'

class ImageSorter
    def initialize(directory, verbose=false)
      @directory = directory
      @verbose = verbose
      @rules = {}
      @logger = Logger.new(STDOUT)
      rcfile = File.join(@directory, ".imgsortrc")
      if File.exists? rcfile then
          contents = File.read rcfile  
          @rules = JSON.load contents
          if @rules.include? "default" then @rules.default = @rules["default"] end
      else
          @rules = {
              "16x9"    => "16x9",
              "16x10"   => "16x10",
              "4x3"     => "4x3",
              "default" => "misc"
          }
          @rules.default = @rules["default"]
      end
    end

    attr_reader :directory, :rules

    def sort
        Dir.entries(@directory)
            .map{|basename| File.join @directory, basename}
            .select{|imgfile| File.file? imgfile}
            .each{ |imgfile| sort_img imgfile }
    end

    def sort_img(imgfile)
        # If this file's filename matches the ignorepattern, skip it.
        return if @rules.include? 'ignore' and @rules['ignore'].any? {|ignorepattern| imgfile.match ignorepattern}

        begin
            img = Image.new imgfile

            # Target directory is determined by the rules object.
            targetdir = File.join @directory, @rules[img.aspectratio]
            if not File::exists? targetdir
              if File::directory? targetdir
                @logger.warn "  #{targetdir} exists but is not a directory. Skipping #{img.filename}." if @verbose
              else
                @logger.info "  creating directory #{targetdir}" if @verbose
                FileUtils.mkdir targetdir
              end
            end

            @logger.info "  moving #{img.filename} to #{targetdir}" if @verbose
            FileUtils.move(img.filename, targetdir)
        rescue NonImageFileError
            @logger.warn "#{imgfile} is not an image. Skipping" if @verbose
        rescue Exception => e
            @logger.error <<-ERR
                Error encountered with #{imgfile}. Moving on.
                #{e.message}
                #{e.backtrace.inspect}
            ERR
        end
    end
end

class FSWatchImageSorter < ImageSorter
    require 'listen'
    def initialize(directory, logger=Logger.new(STDOUT))
        super(directory, true)
        @logger = logger
    end
    def start
        @notifier = Listen::Listener.new(@directory, :ignore => %r{^(.imgsortrc|imgsort.log)}) do |modified, added, removed|
            added.each { |fname| sort_img fname }
        end
        @notifier.start
    end
    def stop
        @notifier.stop
    end
end
