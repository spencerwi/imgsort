Gem::Specification.new do |s|
    s.name          = 'imgsort'
    s.version       = '0.8.0'
    s.date          = '2014-02-11'
    s.summary       = 'imgsort'
    s.description   = "Sorts images in a given directory by aspect ratio, optionally using a per-folder rules file (named '.imgsortrc') for destination folder names."
    s.authors       = ["Spencer Williams"]
    s.email         = "spencerwi@gmail.com"
    s.homepage      = 'http://spencerwi.com'
    s.require_path  = "lib"
    s.executables   << 'imgsort'
    s.add_runtime_dependency 'docopt',          '~> 0.5'
    s.add_runtime_dependency 'fastimage',       '~> 1.2'
    s.add_runtime_dependency 'listen',          '~> 1.2'
    s.add_runtime_dependency 'daemons'
    s.add_development_dependency 'rspec'
end
