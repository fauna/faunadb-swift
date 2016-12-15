Pod::Spec.new do |s|
  s.name             = "FaunaDB"
  s.version          = "0.0.1"
  s.summary          = "Swift driver for FaunaDB."
  s.homepage         = "https://github.com/faunadb/faunadb-swift"
  s.author           = { "Fauna, Inc" => "priority@fauna.com" }
  s.license          = { type: 'Mozilla Public License 2.0', file: 'LICENSE' }
  s.source           = { git: "https://github.com/faunadb/faunadb-swift.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/faunadb'
  s.source_files     = 'Sources/**/*.swift'

  # Multi platform support
  s.ios.deployment_target     = '9.0'
  s.osx.deployment_target     = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'
end
