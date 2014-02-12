require 'imgsort/image'

def get_resource_path(filename)
    File.join File.dirname(__FILE__), "resources", filename
end

describe Image do
    it "throws NonImageFileError when initialized with a non-image file" do
        non_image_file_name = get_resource_path "non_image.csv"
        expect { Image.new non_image_file_name }.to raise_error(NonImageFileError)
    end

    it "reads height and width of an image file on initialization" do
        image_file_name = get_resource_path "350x150.gif"
        image = Image.new image_file_name
        expect(image.width).to eq 350
        expect(image.height).to eq 150 
    end

    describe "#aspectratio" do
        it "returns the aspect ratio in WxH ratio format" do
            image_file_name = get_resource_path "350x150.gif"
            image = Image.new image_file_name
            expect(image.aspectratio).to eq "7x3"
        end

        it "reduces to 16x10 rather than 8x5" do
            image_file_name = get_resource_path "160x100.gif"
            image = Image.new image_file_name
            expect(image.aspectratio).to eq "16x10"
        end
    end
end
