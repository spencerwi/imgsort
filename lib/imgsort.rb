require 'logger'
require 'fileutils'
require 'fastimage'

# Exception class for non-image files
class NonImageFileError < StandardError 
end

# An image class to handle aspect ratio calc and sorting
class Image
  def initialize(filename)
    raise NonImageFileError, "#{filename} is not an image" unless [:gif, :jpg, :jpeg, :png].include? FastImage.type(filename)
    @filename = filename
    @width, @height = FastImage.size(filename)
  end

  attr_reader :filename, :width, :height

  # Get image aspect ratio
  def aspectratio
      if not @ratio then
          # Only calc the ratio the first time. Memoization!
          @ratio = Rational(@width, @height) # Ruby reduces fractions for us! How handy.
      end

      if @ratio == Rational(16, 10) # 16x10 is a special case, since we don't want it reduced down to 8x5
          return "16x10"
      else
          return "#{@ratio.numerator}x#{@ratio.denominator}" # Return the aspect ratio in WxH format
      end
  end
end

class ImageSorter
    def initialize(directory, verbose=false)
      @directory = directory
      @verbose = verbose
      @rules = {}
      @logger = Logger.new(STDOUT)
      rcfile = File.join(@directory, ".imgsortrc")
      if File.exists? rcfile then
          File.readlines(rcfile).each do |line|
            ratio, folder = line.split(':').map { |e| e.strip() }
            @rules[ratio] = folder
            if @rules.include? "default" then @rules.default = @rules["default"] end
          end
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

    attr_reader :directory

    def sort
        Dir.entries(@directory).select{|imgfile| File.file? imgfile}.each do |imgfile|
            begin
                sort_img(imgfile)
            end
        end
    end

    def sort_img(imgfile)
        # If this file's filename matches the ignorepattern, skip it.
        return if @rules.include? 'ignore' and imgfile.match @rules['ignore']

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

            @logger.info "  moving #{img.filename} to #{targetdir}"
            FileUtils.move(img.filename, targetdir)
        rescue NonImageFileError
            @logger.warn "#{imgfile} is not an image. Skipping"
        rescue Exception => e
            @logger.error <<-ERR
                Error encountered with #{imgfile}. Moving on.
                #{e.message}
                #{e.backtrace.inspect}
            ERR
        end
    end
end

class InotifyImageSorter < ImageSorter
    require 'rb-inotify'
    def initialize(directory, logger)
        super(directory, true)
        @logger = logger
    end
    def start
        @notifier = INotify::Notifier.new
        @notifier.watch(@directory, :create, :moved_to, :close_write) { |event| sort_img event.name }
        @notifier.run
    end
end
