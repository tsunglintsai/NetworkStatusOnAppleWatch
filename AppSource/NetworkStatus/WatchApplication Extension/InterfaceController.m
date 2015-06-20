//
//  InterfaceController.m
//  wa Extension
//
//  Created by Henry on 6/20/15.
//  Copyright © 2015 Pyrogusto. All rights reserved.
//

#import "InterfaceController.h"
#import "PGNetworkUtility.h"

@interface InterfaceController()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *ipAddress;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *provider;
@property (nonatomic, strong) PGNetworkUtility *networkUtility;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *loadingLabel;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.networkUtility = [[PGNetworkUtility alloc]init];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self.loadingLabel setHidden:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block NSString *ip;
        __block NSString *isp;
        ip = [self.networkUtility getIpAddress];
        if (ip.length > 0){
            isp = [self.networkUtility getISPFromIp:ip];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ip.length > 0){
                [self.ipAddress setText:ip];
                if (isp.length > 0) {
                    [self.provider setText:isp];
                } else {
                    [self.provider setText:@"cannot connect to service"];
                }
            } else {
                [self.ipAddress setText:@"cannot connect to service"];
                [self.provider setText:@""];
            }
            [self.loadingLabel setHidden:YES];
        });
    });
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


@end



