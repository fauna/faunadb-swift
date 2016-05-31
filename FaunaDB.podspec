Pod::Spec.new do |s|
  s.name             = "FaunaDB"
  s.version          = "1.0.0"
  s.summary          = "Swift client for FaunaDB."
  s.homepage         = "https://github.com/faunadb/faunadb-swift"
  s.license          = { type: 'Mozilla Public License 2.0', file: 'LICENSE' }
  s.author           = { "Fauna, Inc" => "priority@faunadb.com" }
  s.source           = { git: "git@github.com:faunadb/faunadb-swift.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/faunadb'
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.ios.source_files = 'Sources/**/*'
  # s.ios.frameworks = 'UIKit', 'Foundation'
  # s.dependency 'Eureka', '~> 1.0'
end
