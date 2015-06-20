//
//  PGNetworkUtility.m
//  Test2
//
//  Created by Henry on 6/20/15.
//  Copyright © 2015 Pyrogusto. All rights reserved.
//

#import "PGNetworkUtility.h"

static NSString *const kPGIpLookUpServer = @"http://whatismyipaddress.com/ip-lookup";
static NSString *const kPGIpWhoIsServerUrl = @"https://www.ultratools.com/tools/ipWhoisLookupResult?ipAddress=";

@interface PGNetworkUtility()
@end

@implementation PGNetworkUtility

- (NSString*)getIpAddress {
    NSURLSessionDataTask *postDataTask = [[NSURLSessionDataTask alloc] init];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kPGIpLookUpServer]];
    NSURLSession *session = [NSURLSession sharedSession];
    __block NSString *result;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"cannot get ip address:%@",[error description]);
        } else {
            result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            result = [self parseIpAddressFromHtml:result];
        }
        dispatch_semaphore_signal(sem);
    }];
    [postDataTask resume];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return result;
}

- (NSString *)parseIpAddressFromHtml:(NSString*)html {
    NSString *result;
    NSString *prefixString = @"<input type=\"TEXT\" name=\"LOOKUPADDRESS\" value=\"";
    NSRange contentPrefixRange = [html rangeOfString:prefixString];
    if (contentPrefixRange.location != NSNotFound) {
        NSString *contentFromPrefix = [html substringFromIndex:contentPrefixRange.location+prefixString.length];
        NSRange contentRange = [contentFromPrefix rangeOfString:@"\""];
        if (contentRange.location != NSNotFound) {
            result = [contentFromPrefix substringToIndex:contentRange.location];
        }
    }
    return result;
}

- (NSString *)parseISPFromHtml:(NSString*)html {
    NSString *result;
    NSString *prefixString = @"<span class=\"label\">Customer:&nbsp;</span>";
    NSRange contentPrefixRange = [html rangeOfString:prefixString];
    if (contentPrefixRange.location != NSNotFound) {
        NSString *contentFromPrefix = [html substringFromIndex:contentPrefixRange.location+prefixString.length];
        NSRange contentRange = [contentFromPrefix rangeOfString:@"</span>"];
        if (contentRange.location != NSNotFound) {
            NSString *tagPrefix = @"<span class=\"value\">";
            NSString *contentWithTagPrefix = [contentFromPrefix substringToIndex:contentRange.location];
            NSRange contentStartRange = [contentWithTagPrefix rangeOfString:tagPrefix];
            if (contentStartRange.location != NSNotFound) {
                result = [contentWithTagPrefix substringFromIndex:contentStartRange.location + tagPrefix.length];
            }
        }
    }
    return result;
}

- (NSString*)getISPFromIp:(NSString*)ip {
    __block NSString *result;
    NSURLSessionDataTask *postDataTask;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kPGIpWhoIsServerUrl, ip]]];
    NSURLSession *session = [NSURLSession sharedSession];
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"cannot get ip address:%@",[error description]);
        } else {
            result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            result = [self parseISPFromHtml:result];
        }
        dispatch_semaphore_signal(sem);
    }];
    [postDataTask resume];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return result;
}

@end
