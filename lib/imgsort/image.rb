require 'logger'
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
