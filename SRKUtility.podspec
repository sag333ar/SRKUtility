#
# Be sure to run `pod lib lint SRKUtility.podspec` to ensure this is a valid spec.
#

Pod::Spec.new do |s|
	s.version		=	'6.0.1'
	s.name			=	'SRKUtility'
  	s.summary  	 	=   'A pod which helps you to easily save values to NSUserDefaults, display progressHUD and check Network Reachability. base64 data conversion.'
	s.authors		=	{ "Sagar Kothari" => "sag333ar@gmail.com" }
	s.homepage		=	"http://sagarrkothari.com"
	s.license		=	{ :type	=> 'MIT' }
	s.platform		=	:ios
	s.ios.deployment_target = '9.0'

	s.source        =   { 
							:git => 'https://github.com/sag333ar/SRKUtility.git', 
							:branch => 'master', :tag => s.version 
						}
	s.social_media_url = 'https://twitter.com/sag333ar'
	s.documentation_url = 'https://github.com/sag333ar/SRKUtility'

	s.subspec 'Utilities' do |sub|
		sub.source_files	=	'SRKUtility-Source/Utility/Utility.swift'
	end

	s.subspec 'Strings' do |sub|
		sub.source_files	=	'SRKUtility-Source/Strings/StringHelper.swift'
	end

	s.subspec 'ImageView' do |sub|
		sub.source_files	=	'SRKUtility-Source/UIImageView/UIImageHelper.swift'
	end

	s.frameworks 		= 	'UIKit', 'Foundation', 'AVFoundation', 'MediaPlayer'
	s.requires_arc = true
	s.dependency	 		'MBProgressHUD'
	s.dependency 			'KSReachability'

end