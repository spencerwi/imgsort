Gem::Specification.new do |s|
    s.name          = 'imgsort'
    s.version       = '0.2.1'
    s.date          = '2013-03-12'
    s.summary       = 'imgsort'
    s.description   = "Sorts images in a given directory by aspect ratio, optionally using a per-folder rules file (named '.imgsortrc') for destination folder names."
    s.authors       = ["Spencer Williams"]
    s.email         = "spencerwi@gmail.com"
    s.homepage      = 'http://ninjatricks.net'
    s.executables   << 'imgsort'
    s.add_runtime_dependency 'docopt',          '~> 0.5'
    s.add_runtime_dependency 'fastimage',       '~> 1.2'
    s.add_runtime_dependency 'ruby-inotify',    '~> 1.0'
end
