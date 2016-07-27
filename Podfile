platform :ios, '8.0'

source 'https://github.com/techery/CocoaPodsSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

def with_carthage
	pod 'MagicalRecord', '2.3.2' #+

	pod 'FXKeychain', '1.5.3'#+	
	
	pod 'SDWebImage', '3.7.5' #+

	pod 'CocoaLumberjack', '2.2.0' #+

	pod 'Masonry', '0.6.4' #+
	pod 'MBProgressHUD', '0.9.2' #+
	pod 'OAStackView', '1.0.1' #+

	pod 'TTTAttributedLabel', '1.13.4' #+
	pod 'SlackTextViewController', '1.9' #+
	pod 'AsyncDisplayKit', '1.9.7.2' #+
	pod 'pop', '1.0.9' #+

	pod 'TLLayoutTransitioning', '1.0.9' #+
	pod 'AMPopTip', '0.10.1.1' #+
	pod 'SZTextView', '1.2.1' #+
end

def with_carthage_in_future

	pod 'CSLinearLayoutView', '1.0' #- forked +
	pod 'HMSegmentedControl', '1.4.0' #- forked + 
	pod 'UAProgressView', '0.1.3'#- forked +
	pod 'NYSegmentedControl', '1.0.7' #- forked +
	pod 'CustomBadge', '3.0.0' #- forked +
	pod 'JNWSpringAnimation', '0.7.1' #- forked +
	pod 'KNSemiModalViewController', '0.3' #- forked +
	pod 'WYPopoverController', '0.1.8' #- forked +
	pod 'CCHMapClusterController', '1.7.0' #- forked +
	pod 'RATreeView', '0.9.2'#- forked +
	pod 'SCLAlertView-Objective-C', '0.9.1' #- forked +   	
    pod 'BABCropperView', '0.4.7.1' #- forked +

end

def wont_fork
	pod 'NMRangeSlider', '1.2.1'#- forked => resources!
end

def dt_shared_pods
	
	# Architecture Helpers
	pod 'CriolloKitDI', '0.0.6.1' #- forked +
	pod 'FLUX', '0.2.0' #- forked
	pod 'TEArrayDiffCalculator', '0.1.2' #- forked +
	pod 'Oscar', '1.0.1' #- forked +
	
	pod 'MTDates', '1.0.3.1' #- forked +
	pod 'BlocksKit', '2.2.5' #- need to be removed
	
	pod 'Overcoat/ReactiveCocoa', '2.1.1' #±(for 4.0)
	pod 'SSDataSources', '0.8.5' #- forked +

	# MapView clustering sugar
	pod 'ABFRealmMapView' #- need to be removed

	# xmpp 
	pod 'XMPPFramework/Core', '3.6.6.1' #- forked Kiev?
	pod 'XMPPFramework/Roster', '3.6.6.1' #- forked Kiev?
	pod 'XMPPFramework/XEP-0059', '3.6.6.1' #- forked Kiev?
	pod 'XMPPFramework/XEP-0045', '3.6.6.1' #- forked Kiev?
	pod 'XMPPFramework/XEP-0199', '3.6.6.1' #- forked Kiev?
end

target :CarthageTest, :exclusive => true do
	dt_shared_pods

# Support SDKs	
	
	pod 'FBSDKCoreKit', '4.10.0' #-
	pod 'FBSDKLoginKit', '4.10.0' #-
	pod 'FBSDKShareKit', '4.10.0' #-

	pod 'Fabric', '1.6.6' #-
	pod 'Crashlytics', '3.7.0' #-
    pod 'NewRelicAgent', '5.5.2' #-
    pod 'AdobeMobileSDK', '4.10.0' #-
    pod 'apptentive-ios', '2.1.2' #- forked +

    with_carthage_in_future

end

