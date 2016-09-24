#
# Be sure to run `pod lib lint SRKUtility.podspec` to ensure this is a valid spec.
#

Pod::Spec.new do |s|
	s.version		=	'5.0.6'
	s.name			=	'SRKUtility'
  	s.summary  	 	=   'A pod which helps you to easily save values to NSUserDefaults, display progressHUD and check Network Reachability. base64 data conversion.'
	s.authors		=	{ "Sagar Kothari" => "sag333ar@gmail.com" }
	s.homepage		=	"http://sagarrkothari.com"
	s.license		=	{ :type	=> 'MIT' }
	s.ios.deployment_target = '9.0'
  	s.source        =   { 
  							:git => 'https://github.com/sag333ar/SRKUtility.git', 
  							:branch => 'master', :tag => s.version 
  						}
	s.preserve_paths =  'SRKClasses', 'SRKImages'
	s.resources 	= 	'SRKUtility/SRKImages/*.png'
  	s.source_files	=	'SRKUtility/SRKClasses/*.{h,m}', 'SRKUtility/*.{swift}'
 	s.dependency 		'MBProgressHUD'
 	s.dependency 		'KSReachability'
	s.frameworks 	= 	'UIKit', 'Foundation'
	s.requires_arc = true
end