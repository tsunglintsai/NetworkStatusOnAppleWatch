//
//  PGNetworkUtility.h
//  Test2
//
//  Created by Henry on 6/20/15.
//  Copyright © 2015 Pyrogusto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGNetworkUtility : NSObject
- (NSString*)getIpAddress;
- (NSString*)getISPFromIp:(NSString*)ip;
@end
