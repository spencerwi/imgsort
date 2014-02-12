require 'imgsort/imagesorter'
require 'fileutils'

resources_path = File.join File.dirname(__FILE__), "resources"

def cleanup_resources_folder 
    resources_path = File.join File.dirname(__FILE__), "resources"
    sixteen_by_ten_image = File.join(resources_path, "16x10", "160x100.gif")
    if File.file? sixteen_by_ten_image then
        FileUtils.move sixteen_by_ten_image, resources_path
        FileUtils.rmdir File.join(resources_path, "16x10")
    end

    sixteen_by_ten_image_copy = File.join(resources_path, "160x100_copy.gif")
    if File.exists? sixteen_by_ten_image_copy then
        File.delete sixteen_by_ten_image_copy 
    end

    misc_size_image = File.join(resources_path, "misc", "350x150.gif")
    if File.file? misc_size_image then
        FileUtils.move misc_size_image, resources_path
        FileUtils.rmdir File.join(resources_path, "misc")
    end

    test_imgsortrc = File.join(resources_path, ".imgsortrc")
    if File.exists? test_imgsortrc then
        File.delete test_imgsortrc
    end
end

describe ImageSorter do
    after(:each) do
        cleanup_resources_folder
    end

    it "uses a set of default sorting rules if no .imgsortrc is specified" do
        sorter = ImageSorter.new resources_path
        default_rules = {
            "16x9"    => "16x9",
            "16x10"   => "16x10",
            "4x3"     => "4x3",
            "default" => "misc"
        }
        expect(sorter.rules).to eq default_rules
    end

    it "reads sorting rules from a 'ratio: dirname'-formatted .imgsortrc file in the target directory" do
        require 'json'
        File.open File.join(resources_path, ".imgsortrc"), "w"  do |f|
            f.write({"16x10" => "foo"}.to_json)
        end

        sorter = ImageSorter.new resources_path
        expect(sorter.rules["16x10"]).to eq "foo"
    end

    it "uses the 'default' rule to sort images with an aspect ratio for which no rule is defined" do
        sorter = ImageSorter.new resources_path
        expect(sorter.rules["foobar"]).to eq sorter.rules["default"]
    end

    it "creates directories as needed" do
        destination_file = File.join resources_path, "16x10"
        expect(File.exists? destination_file).to eq false
        sorter = ImageSorter.new resources_path
        sorter.sort
        expect(File.exists? destination_file).to eq true
    end

    it "sorts all images in a directory according to its aspect ratio rules" do
        destination_files = [
            File.join(resources_path, "16x10", "160x100.gif"),
            File.join(resources_path, "misc",  "350x150.gif")
        ]
        expect(destination_files.any?{|f| File.exists? f}).to eq false
        sorter = ImageSorter.new resources_path
        sorter.sort
        expect(destination_files.all?{|f| File.exists? f}).to eq true
    end

    it "leaves non-image files where they are" do
        non_image_file = File.join resources_path, "non_image.csv"
        expect(File.exists? non_image_file).to eq true
        sorter = ImageSorter.new resources_path
        sorter.sort
        expect(File.exists? non_image_file).to eq true
    end
end

describe FSWatchImageSorter do
    after(:each) do
        cleanup_resources_folder
    end
    it 'listens for changes in its given directory and sorts changed files' do
        watcher = FSWatchImageSorter.new resources_path
        source_file = File.join(resources_path, "160x100.gif")
        copy_file = File.join(resources_path, "160x100_copy.gif")
        watcher.start
        watcher.should_receive("sort_img").with copy_file
        FileUtils.copy source_file, copy_file
        sleep 2 # give it long enough to fire up the listener and do the move
        watcher.stop
    end
end
