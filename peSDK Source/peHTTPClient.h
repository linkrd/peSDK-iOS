//
//  peHTTPClient.h
//  peSDK iOS
//  
//  Created by Thieu Huynh on 2013-04-26.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import "AFHTTPClient.h"

@protocol peHTTPClientDelegate;

/**
 `peHTTPClient` is a subclass of `AFHTTPClient` 
 
 
 */
@interface peHTTPClient : AFHTTPClient {
    id delegate;
    NSString* urlPathString;
    NSString* configAuthString;
}

/**
 The url used as the base for paths specified in methods such as `getPath:parameters:success:failure`
 */
@property (strong, nonatomic) NSString *urlPathString;
@property (strong, nonatomic) NSString *configAuthString;
@property (strong, nonatomic) id<peHTTPClientDelegate> delegate;

+ (peHTTPClient *) sharedClient;
- (NSString *) getURLPath;
- (NSString *) md5:(NSString *) input;
- (NSString *) buildAuth:(NSString*)key;
- (NSDictionary *) buildParamsWithAction:(NSString*)_action userKey:(NSString*)_userKey userValue:(NSString*)_userValue extraParams:(NSDictionary*)_extraParams;
- (void) fetchConfigWithSettings:(NSDictionary*)configSettings;
//- (void) doWithParams:(NSDictionary*)params block:(void (^)(NSDictionary *responseJSON, NSError *error))block;
- (void) doWithAction:(NSString*)action userKey:(NSString*)userKey userValue:(NSString*)userValue extraParams:(NSDictionary *)extraParams;
+ (void) sendSynchronousRequestWithParameters:(NSDictionary *) params success:(void (^)(id responseJSON)) successCallback failure:(void (^)(NSError * error, NSString * errorMsg)) errorCallback;



@end


@protocol peHTTPClientDelegate <NSObject>

- (void)actionCompleted:(NSDictionary*)responseJSON;
- (void)actionCompletedWithErrors:(NSArray*)errors response:(NSDictionary*)responseJSON;

@end