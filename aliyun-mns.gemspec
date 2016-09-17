# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name          = 'aliyun_mns_queue'
  s.version       = '0.0.2'
  s.authors       = ['Alvin Ye']
  s.email         = ['alvin.ye.cn@gmail.com']
  s.description   = %q{ruby client for aliyun mns queue without topic}
  s.summary       = %q{ruby client for aliyun mns queue without topic }
  s.homepage      = 'https://github.com/alvin2ye/aliyun_mns'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|s.features)/})
  s.require_paths = ['lib']

  s.add_runtime_dependency "crack"
  s.add_runtime_dependency "json"
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake', '~> 11.2.2'
end
