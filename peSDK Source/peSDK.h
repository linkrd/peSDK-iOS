//
//  peSDK.h
//  peSDK iOS
//
//  Created by Thieu Huynh on 2013-04-18.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

/*
 * peSDK iOS
 *
 *
 *
 *
 */

#import "peConfig.h"
#import "peConstants.h"
#import "peHTTPClient.h"
#import "peSDKDelegate.h"

@interface peSDK : NSObject <peHTTPClientDelegate>  {
    NSDictionary *configVars;
    NSMutableDictionary *userProfile;
    NSDictionary *params;
    BOOL isAuthenticated;
    id delegate;
}


@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) NSDictionary *config;
@property (nonatomic, assign) BOOL isAuthenticated;
@property (nonatomic, strong) NSDictionary *configVars;
@property (nonatomic, strong) NSDictionary *userProfile;
@property (nonatomic, strong) id<peSDKDelegate> delegate;

- (id) initWithSettings:(NSDictionary*)_config delegate:(id)delegate;
- (BOOL) isOpen;
- (NSDictionary*) getRequiredFields;
- (NSDictionary*) getAllFields;
- (NSDictionary*) getEntryPeriod;
- (NSDictionary*) getPrizingInfo;
- (BOOL) isAuthenticated;
- (void) setUserParams:(NSDictionary*)userParameters;
- (BOOL) authenticateOnServer:(NSDictionary*)userParameters error:(NSError**)error;
- (NSDictionary*) getCurrentProfileParams;
- (NSDictionary*) getUserProfile;
- (void) setUserProfile:(NSDictionary*)profileFields params:(NSDictionary*)userParameters error:(NSError**)error;
- (BOOL) canEnter:(NSDictionary*) userParameters error:(NSError**)error;
- (NSString*) nextPlay:(NSDictionary*) userParameters error:(NSError**)error;
- (NSDictionary*) enterSweeps:(NSDictionary*)userParameters error:(NSError**)error;
- (NSDictionary*) enterInstantWin:(NSDictionary*)userParameters error:(NSError**)error;

- (NSArray*) gameHistoryData:(NSArray*)historyArray;
- (NSDictionary*) formatGameData:(NSDictionary*) serverData gameType:(NSString*)gameType;
- (void) setProfileData:(NSDictionary*) profileData;
- (void) buildAndSend:(NSString*) _action  params:(NSDictionary*)userParameters error:(NSError**)error;

/*
- (void) newErrorWithNLS:nls code:(int)code action:(NSString*)action;
- (BOOL) hasErrors;
- (NSError*) getLastError;
- (NSArray*) getAllErrors;
- (void) flushErrors;
*/
@end
