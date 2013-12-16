//
//  peHTTPClient.m
//  peSDK iOS
//
//  Created by Thieu Huynh on 2013-04-26.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import "peConfig.h"
#import "peConstants.h"
#import "peHTTPClient.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import <CommonCrypto/CommonDigest.h>

@implementation peHTTPClient

@synthesize delegate, urlPathString, configAuthString;

+ (peHTTPClient *) sharedClient {
    
    static peHTTPClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:peAPIBaseUrlString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
      
    if ([[url scheme] isEqualToString:@"https"] && [[url host] isEqualToString:@"contest.linkrd.com"]) {
        // set to AFSSLPinningModePublicKey if certificate is not required
        //[self setDefaultSSLPinningMode:AFSSLPinningModePublicKey];
        // AFSSLPinningModeCertificate - a certificate is required, check sample code for contest.linkrd.com.cer file
        [self setDefaultSSLPinningMode:AFSSLPinningModeCertificate];
    }
    
    return self;
}

- (NSString *) getURLPath {
    return urlPathString;
}

+ (void) sendSynchronousRequestWithParameters:(NSDictionary *) params
                           success:(void (^)(id responseJSON)) successCallback
                           failure:(void (^)(NSError * error, NSString * errorMsg)) errorCallback {
    
    NSURLResponse *response = nil;
    NSError *error = nil;
        
    NSMutableURLRequest *request = [[peHTTPClient sharedClient] requestWithMethod:peRequestMethod path:[[peHTTPClient sharedClient] getURLPath] parameters:params];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(error) {
        errorCallback(error, @"NSURLConnection error");
    } else {
        id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            errorCallback(error, @"NSJSONSerialization error");
        } else{
            successCallback(json);
        }
    }
}

- (NSMutableDictionary *) buildParamsWithAction:(NSString*)action userKey:(NSString*)userKey userValue:(NSString*)userValue extraParams:(NSDictionary *)extraParams {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   action, peActionKey,
                                   userValue, userKey,
                                   peResponseFormat, peResponseFormatKey,
                                   [self buildAuth:userValue], peAuthKey, nil];
    
    if (extraParams != nil) {
        [params addEntriesFromDictionary:extraParams];
    }

    return params;
}

- (void) doWithAction:(NSString*)action userKey:(NSString*)userKey userValue:(NSString*)userValue extraParams:(NSDictionary *)extraParams {
    
    NSDictionary *params = [self buildParamsWithAction:action userKey:userKey userValue:userValue extraParams:nil];
    
    [self getPath:urlPathString parameters:params success:^(AFHTTPRequestOperation *operation, id responseJSON) {
        if ([[[responseJSON objectForKey:@"result"] valueForKey:@"success"] intValue] == 1) {
            [self.delegate actionCompleted:responseJSON];
        } else {
            NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[responseJSON objectForKey:@"result"]];
            NSArray *errors = [[NSArray alloc] initWithArray:[result objectForKey:@"errors"]];
            [self.delegate actionCompletedWithErrors:errors response:responseJSON];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    }];
}


- (void) fetchConfigWithSettings:(NSDictionary*)configSettings {
    
    urlPathString = [[NSString alloc] initWithFormat:@"%@/%@/%@", [configSettings valueForKey:peClientKey], [configSettings valueForKey:pePromoKey], peAPIString];
    configAuthString = [[NSString alloc] initWithString:[configSettings valueForKey:peConfigAuthKey]];
        
    [self doWithAction:@"getconfig" userKey:peContestAdminIDKey userValue:[configSettings valueForKey:peContestAdminIDKey] extraParams:nil];
}

- (NSString *) buildAuth:(NSString*)key {
    return [self md5:[key stringByAppendingString:configAuthString]];
}

- (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); 
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return  output;
}

@end
