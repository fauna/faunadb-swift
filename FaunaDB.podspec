Pod::Spec.new do |s|
  s.name             = "FaunaDB"
  s.version          = "1.0.0"
  s.summary          = "Swift client for FaunaDB."
  s.homepage         = "https://github.com/faunadb/faunadb-swift"
  s.license          = { type: 'Mozilla Public License 2.0', file: 'LICENSE' }
  s.author           = { "Fauna, Inc" => "priority@faunadb.com" }
  s.source           = { git: "https://github.com/faunadb/faunadb-swift.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/faunadb'
  s.requires_arc = true
  s.source_files = 'Sources/**/*.swift'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
end
