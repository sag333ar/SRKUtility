#
# Be sure to run `pod spec lint SRKUtility.podspec` to ensure this is a valid spec.
#

Pod::Spec.new do |s|
	s.version		=	'2.0.2'
	s.name			=	'SRKUtility'
    s.summary       =   'A pod which helps you to easily save values to NSUserDefaults, display MBProgressHUD and check Network Reachability.'
	s.authors		=	{ "Sagar Kothari" => "sag333ar@gmail.com" }
	s.homepage		=	"http://sagarrkothari.com"
	s.license		=	{ :type	=> 'BSD' }
	s.platform		=	:ios, '8.0'
    s.requires_arc  =   true
    s.source        =   { :git => 'https://github.com/sag333ar/SRKUtility.git', :branch => 'master', :tag => s.version }
    s.subspec 'SRKUtility' do |srkutility|
        srkutility.source_files	=	'SRKUtility/*.{swift}'
    end
    s.dependency 'KSReachability'
	s.dependency 'MBProgressHUD'
	
	s.frameworks = 'UIKit', 'Foundation'
end