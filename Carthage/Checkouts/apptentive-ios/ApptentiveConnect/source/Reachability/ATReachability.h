//
//  ATReachability.h
//  ApptentiveConnect
//
//  Created by Andrew Wooster on 4/13/11.
//  Copyright 2011 Apptentive, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

typedef enum {
	ATNetworkNotReachable,
	ATNetworkWifiReachable,
	ATNetworkWWANReachable
} ATNetworkStatus;

extern NSString *const ATReachabilityStatusChanged;


@interface ATReachability : NSObject
+ (ATReachability *)sharedReachability;
- (ATNetworkStatus)currentNetworkStatus;
@end
