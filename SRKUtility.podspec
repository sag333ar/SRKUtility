#
# Be sure to run `pod lib lint SRKUtility.podspec` to ensure this is a valid spec.
#

Pod::Spec.new do |s|
	s.version		=	'5.1.17'
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
	s.documentation_url = 'https://github.com/sag333ar/SRKUtility/wiki'

	s.subspec 'Camera' do |sub|
		# sub.preserve_paths	= 	'SRKClasses', 'SRKImages'
		sub.resources 		= 	'SRKUtility-Source/Camera/SRKImages/*.png'
		sub.source_files	=	'SRKUtility-Source/Camera/SRKClasses/*.{h,m}', 'SRKUtility-Source/Camera/SRKCamera.swift'
	end

  s.subspec 'Request' do |sub|
  	sub.source_files	=	'SRKUtility-Source/RequestManager/SRKRequestManager.swift'
  end

	s.subspec 'DeviceType' do |sub|
		sub.source_files	=	'SRKUtility-Source/Device/SRKDeviceType.swift'
	end
	
	s.subspec 'Utilities' do |sub|
		sub.source_files	=	'SRKUtility-Source/Utility/SRKUtility.swift'
	end

	s.subspec 'Strings' do |sub|
		sub.source_files	=	'SRKUtility-Source/Strings/StringHelper.swift'
	end

	s.subspec 'ImageView' do |sub|
		sub.source_files	=	'SRKUtility-Source/UIImageView/UIImageHelper.swift'
	end

	s.subspec 'Controls' do |sub|
		sub.source_files		=	'SRKUtility-Source/Controls/*.{swift}'
		sub.resource_bundles	=	{
			'Controls' => [
				'SRKUtility-Source/Controls/*.{xib}'
			]
		}
	end

	s.subspec 'O365' do |sub|
		# sub.preserve_paths  = 	'Helpers', 'Model'
		sub.source_files    =  	'SRKUtility-Source/O365/Helpers/*.{h,m}', 'SRKUtility-Source/O365/Model/*.{h,m}'
	end

	s.frameworks 	= 	'UIKit', 'Foundation', 'AVFoundation'
	s.requires_arc = true
	s.dependency	 		'MBProgressHUD'
	s.dependency 			'KSReachability'
	s.dependency 			'ADALiOS', '~> 1.2'
end