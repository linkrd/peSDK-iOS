//
//  peSDK.m
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

#import "peSDK.h"
#import "peConstants.h"
#import "peError.h"

#if !__has_feature(objc_arc)
#error PE iOS SDK must be built with ARC.
// You can turn on ARC for only PE SDK files by adding -fobjc-arc to the build phase for each of its files.
#endif


@implementation peSDK

@synthesize delegate, userProfile, params, isAuthenticated, config, configVars;

- (id) initWithSettings:(NSDictionary*)settings delegate:(id)_delegate {
    if (self = [super init]) {
        if ([settings valueForKey:peClientKey] && [settings valueForKey:pePromoKey] && [settings valueForKey:peConfigAuthKey] && [settings valueForKey:peContestAdminIDKey]) {
            configVars = settings;
            self.delegate = _delegate;
            [peHTTPClient sharedClient].delegate = self;
            [[peHTTPClient sharedClient] fetchConfigWithSettings:settings];
        } else {
            [NSException raise:@"Invalid peSDK Settings" format:@"Settings are invalid: %@", settings];
        }
    }
    return self;
}

/**
    isOpen will tell you if the contest can be played
 
    @return boolean isopen
 */
- (BOOL) isOpen {
    return [[peConfig sharedConfig] isOpen];
}

/**
    getRequiredFields will get an array of the required fields
 
    @return NSDictionary of required fields
 */
- (NSDictionary*) getRequiredFields {
    return [[peConfig sharedConfig] getRequiredFields];
}

/**
    getAllFields will get an array of the fields
 
    @return NSDictionary of fields
 */
- (NSDictionary*) getAllFields {
    return [[peConfig sharedConfig] getAllFields];
}

/** 
    getEntryPeriod gets data relating to when the contest opens and closes
 
    @return NSDictionary containing open & close dates
 */
- (NSDictionary*) getEntryPeriod {
    return [[peConfig sharedConfig] getEntryPeriod];
}


/**
    getPrizingInfo gets data relating winning levels
 
    @return NSDictionary containing winlevel information
 */
- (NSDictionary*) getPrizingInfo {
    
    if ([[peConfig sharedConfig] isInstantWin]) {
        return [[peConfig sharedConfig] getPrizingInfo];
    } 
    return nil;
}


- (BOOL) isAuthenticated {
    return isAuthenticated;
}

/** 
 *  set user params
 
    @param userParameters NSDictionary containing user parameters, optional is already set

 */

- (void) setUserParams:(NSDictionary*) userParameters {
    if (userParameters != nil) {
        self.params = userParameters;
    }
}

/**
 *  Performs authentication on the server
 
    @param userParameters NSDictionary containing user parameters, optional is already set
    @param error pointer to error 
    @return bool is authentication is successful
 */
- (BOOL) authenticateOnServer:(NSDictionary*)userParameters error:(NSError**)error{
    
    [self setUserParams:userParameters];
    if ([[peConfig sharedConfig] hasRequiredFields:params]) {
        
        NSString *userKey = [[peConfig sharedConfig] getAuthUserField];
        NSDictionary *newParams = [[peHTTPClient sharedClient] buildParamsWithAction:@"auth_only" userKey:userKey userValue:[params valueForKey:userKey] extraParams:params];
        
        __block NSError *serverError;

        [peHTTPClient sendSynchronousRequestWithParameters:newParams success:^(id responseJSON) {
            if ([responseJSON objectForKey:@"auth"] != [NSNull null]) {
                if ([[[responseJSON objectForKey:@"auth"] valueForKey:@"success"] intValue] == 1) {
                    [self setIsAuthenticated:YES];
                    [self setProfileData:[responseJSON objectForKey:@"user_profile"]];
                } else {
                    [self setIsAuthenticated:NO];
                }
            }
            if ([[[responseJSON objectForKey:@"result"] valueForKey:@"success"] intValue] == 0) {
                NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[responseJSON objectForKey:@"result"]];
                NSArray *errorArray = [[NSArray alloc] initWithArray:[result objectForKey:@"errors"]];
                serverError = [peError createNSErrorWithNLS:[errorArray lastObject] action:@"auth_only" code:pe_API_ERROR]; 
            }
        } failure:^(NSError *error, NSString * errorMsg) {
            serverError = error;
        }];
        
        *error = serverError;
        return [self isAuthenticated];
    } else {
        *error = [peError createNSErrorWithNLS:@"missing_required_user_fields" action:@"auth_only" code:pe_API_ERROR]; 
    }
    return NO;
}

/**
 *  getCurrentProfileParams will get the current user's profile values as name/value pairs containing a value
 *
 *  @return dictionary NSDictionary of name value pairs containing the non null user profile fields
 */
- (NSDictionary*) getCurrentProfileParams {
    
    NSMutableDictionary *profileParams = [[NSMutableDictionary alloc] init];
    for (id key in userProfile) {
        if (![key isEqualToString:@"auth"]) {
            [profileParams setObject:[userProfile valueForKey:key] forKey:key];
        }
    }
    return profileParams;
}

/**
 *  Get user profile
 *
 *  @return user profile 
 */
- (NSDictionary*) getUserProfile {
    return userProfile;
}

/**
 *  Get user profile
 *  @param userParameters NSDictionary containing user parameters, optional is already set
 *  @param error pointer to error
 */
- (void) setUserProfile:(NSDictionary*)profileFields params:(NSDictionary*)userParameters error:(NSError**)error  {
    [self setUserParams:userParameters];
    
    NSMutableDictionary *updateParams = [[NSMutableDictionary alloc] initWithDictionary:params];
    for (id key in profileFields) {
        [updateParams setObject:[profileFields valueForKey:key] forKey:key];
    }
    if ([self isOpen]) {
        
        NSError *_error = nil;
        [self buildAndSend:@"updateprofile" params:updateParams error:&_error];
        
        if(_error){
            *error = _error;
        }
    } else {
        NSLog(@"setUserProfile: error");
        *error = [peError createNSErrorWithNLS:@"contest_not_open" action:@"updateprofile" code:pe_API_ERROR];
    }
}

/**
 *  Can enter contest
 *  @param userParameters NSDictionary containing user parameters, optional is already set
 *  @param error pointer to error
 *  @return BOOL
 */
- (BOOL) canEnter:(NSDictionary*) userParameters error:(NSError**)error{
    [self setUserParams:userParameters];
    
    if ([[peConfig sharedConfig] hasRequiredFields:params]) {
        
        NSString *userKey = [[peConfig sharedConfig] getAuthUserField];
        NSDictionary *newParams =[[peHTTPClient sharedClient] buildParamsWithAction:@"canplay" userKey:userKey userValue:[params valueForKey:userKey] extraParams:userParameters];
        
        __block NSError *serverError;
        __block BOOL canPlay = NO;
        [peHTTPClient sendSynchronousRequestWithParameters:newParams success:^(id responseJSON) {
            if ([[[responseJSON objectForKey:@"result"] valueForKey:@"success"] intValue] == 1) {
                canPlay = YES;
            } else{
                NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[responseJSON objectForKey:@"result"]];
                NSArray *errorArray = [[NSArray alloc] initWithArray:[result objectForKey:@"errors"]];
                serverError = [peError createNSErrorWithNLS:[errorArray lastObject] action:@"canplay" code:pe_API_ERROR]; 
            }
        } failure:^(NSError *error, NSString *errorMsg) {
            NSLog(@"error:%@ - %@", error, errorMsg);
            serverError = error;
        }];
        *error = serverError;
        return canPlay;
    } else {
        *error = [peError createNSErrorWithNLS:@"missing_required_user_fields" action:@"canplay" code:pe_API_ERROR]; 
    }
    return NO;
}

/**
 *  Next play
 *  @param userParameters NSDictionary containing user parameters, optional is already set
 *  @param error pointer to error
 *  @return string of next play date
 */
- (NSString*) nextPlay:(NSDictionary*)userParameters error:(NSError**)error {
    [self setUserParams:userParameters];
    
    NSString *userKey = [[peConfig sharedConfig] getAuthUserField];
    NSDictionary *newParams =[[peHTTPClient sharedClient] buildParamsWithAction:@"canplay" userKey:userKey userValue:[params valueForKey:userKey] extraParams:userParameters];
    
    __block NSError *serverError;
    __block NSString *nextPlay = @"";
    [peHTTPClient sendSynchronousRequestWithParameters:newParams success:^(id responseJSON) {

        if ([[[responseJSON objectForKey:@"result"] valueForKey:@"success"] intValue] != 1) {
            NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[responseJSON objectForKey:@"result"]];
            if ([result objectForKey:@"next_play"]) {
                nextPlay = [[NSString alloc] initWithString:[result objectForKey:@"next_play"]];
            }
         }
        
    } failure:^(NSError *error, NSString *errorMsg) {
        NSLog(@"error:%@ - %@", error, error);
        serverError = error;
    }];
    *error = serverError;
    return nextPlay;
}

/**
 *  Enter Sweeps
 *  @param userParameters NSDictionary containing user parameters, optional is already set
 *  @param error pointer to error
 *  @return dictionary NSDictionary of response data from server
 */
- (NSDictionary*) enterSweeps:(NSDictionary*)userParameters error:(NSError**)error  {
    [self setUserParams:userParameters];
    
    NSString *userKey = [[peConfig sharedConfig] getAuthUserField];
    NSDictionary *newParams =[[peHTTPClient sharedClient] buildParamsWithAction:@"instantwin" userKey:userKey userValue:[params valueForKey:userKey] extraParams:userParameters];
    
    __block NSError *serverError;
    __block NSDictionary *gameData = nil;
    if ([self isOpen]) {
        if ([[peConfig sharedConfig] isSweeps]) {
            
            [peHTTPClient sendSynchronousRequestWithParameters:newParams success:^(id responseJSON) {
                
                if ([[[responseJSON objectForKey:@"result"] valueForKey:@"success"] intValue] == 1) {
                    NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[responseJSON objectForKey:@"result"]];
                    if ([[result objectForKey:@"game"] valueForKey:@"gameID"] != [NSNull null]) {
                        gameData = [[NSDictionary alloc] initWithDictionary:[self formatGameData:[result objectForKey:@"game"] gameType:@"sweeps"]];
                    }
                } else{
                    NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[responseJSON objectForKey:@"result"]];
                    NSArray *errorArray = [[NSArray alloc] initWithArray:[result objectForKey:@"errors"]];
                    serverError = [peError createNSErrorWithNLS:[errorArray lastObject] action:@"instantwin" code:pe_API_ERROR];
                }
                
            } failure:^(NSError *error, NSString *errorMsg) {
                NSLog(@"error:%@ - %@", error, error);
                serverError = error;
            }];
            *error = serverError;
        } else {
            *error = [peError createNSErrorWithNLS:@"sweeps_wrong_game_type" action:@"instantwin" code:pe_DATA_ERROR];
        }
    } else {
        *error = [peError createNSErrorWithNLS:@"contest_not_open" action:@"instantwin" code:pe_API_ERROR];
    }
    return gameData;
}


/**
 *  Enter Instant win
 *  @param userParameters NSDictionary containing user parameters, optional is already set
 *  @param error pointer to error
 *  @return dictionary NSDictionary of response data from server
 */
- (NSDictionary*) enterInstantWin:(NSDictionary*)userParameters error:(NSError**)error  {
    [self setUserParams:userParameters];
    
    NSString *userKey = [[peConfig sharedConfig] getAuthUserField];
    NSDictionary *newParams =[[peHTTPClient sharedClient] buildParamsWithAction:@"instantwin" userKey:userKey userValue:[params valueForKey:userKey] extraParams:userParameters];
    
    __block NSError *serverError;
    __block NSDictionary *gameData = nil;
    if ([self isOpen]) {
        if ([[peConfig sharedConfig] isInstantWin]) {
            
            [peHTTPClient sendSynchronousRequestWithParameters:newParams success:^(id responseJSON) {
                
                if ([[[responseJSON objectForKey:@"result"] valueForKey:@"success"] intValue] == 1) {
                    NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[responseJSON objectForKey:@"result"]];
                    if ([[result objectForKey:@"game"] valueForKey:@"gameID"] != [NSNull null]) {
                        gameData = [[NSDictionary alloc] initWithDictionary:[self formatGameData:[result objectForKey:@"game"] gameType:@"instant"]];
                    }
                } else{
                    NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[responseJSON objectForKey:@"result"]];
                    NSArray *errorArray = [[NSArray alloc] initWithArray:[result objectForKey:@"errors"]];
                    serverError = [peError createNSErrorWithNLS:[errorArray lastObject] action:@"instantwin" code:pe_API_ERROR];
                }
                
            } failure:^(NSError *error, NSString *errorMsg) {
                NSLog(@"error:%@ - %@", error, error);
                serverError = error;
            }];
            *error = serverError;
        } else {
            *error = [peError createNSErrorWithNLS:@"instant_wrong_game_type" action:@"instantwin" code:pe_DATA_ERROR];
        }
    } else {
        *error = [peError createNSErrorWithNLS:@"contest_not_open" action:@"instantwin" code:pe_API_ERROR];
    }
    return gameData;
}


/**
 *  Set Profile Data
 *  @param profileData NSDictionary profile data
 
 */
- (void) setProfileData:(NSDictionary*)profileData {
    NSDictionary *profileFields = [[peConfig sharedConfig] getProfileFields];
    NSMutableDictionary *tempUserProfile = [[NSMutableDictionary alloc] init];
    
    for (id index in profileFields) {

        NSString *fieldname = [[profileFields objectForKey:index] objectForKey:@"name"];
        if (![fieldname isEqualToString:@"auth"]) {
            NSMutableDictionary *field = [[NSMutableDictionary alloc] initWithDictionary:[profileFields objectForKey:index]];
            if([profileData valueForKey:fieldname]){
                [field setObject:[profileData valueForKey:fieldname] forKey:@"value"];
            } else {
                [field setObject:nil forKey:@"value"];
            }
            [tempUserProfile setObject:field forKey:fieldname];
        }
    }
    self.userProfile = tempUserProfile;
}

/**
 *  This method allows you to make an asynschronous calls to the server with a specific action. 
 *  Possible actions are: getconfig, auth_only, canplay, updateprofile, gamehistory, instantwin
 
 *  @param action action to perform on the server
 *  @param parameters NSDictionary containing parameters to send to the server
 *  @param error pointer to error
 */
- (void) buildAndSend:(NSString*)_action  params:(NSDictionary*)parameters error:(NSError**)error  {
    
    if ([[peConfig sharedConfig] hasRequiredFields:params]) {
        NSString *userKey = [[peConfig sharedConfig] getAuthUserField];
        [[peHTTPClient sharedClient] doWithAction:_action userKey:userKey userValue:[params valueForKey:userKey] extraParams:parameters];
    } else {
        *error = [peError createNSErrorWithNLS:@"missing_required_user_fields" action:_action code:pe_API_ERROR];
    }
    
}


/**
 *  gameHistoryData
 *  @param historyArray array of game history
 *  @return formatted array of game history
 */
- (NSArray*) gameHistoryData:(NSArray*)historyArray {
    
    NSString *gameType;
    if ([[peConfig sharedConfig] isSweeps]) {
        gameType = @"sweeps";
    } else {
        gameType = @"instant";
    }
    
    NSMutableArray *formattedHistory = [[NSMutableArray alloc] init];
    
    for (id object in historyArray) {
        [formattedHistory addObject:[self formatGameData:object gameType:gameType]];
    }
    
    return formattedHistory;
}


/* Clean up the game data and remove extraneous variables that the server sends back
 *
 * @param serverData NSDictionary of data from the server
 * @param gameType type of contest can be instant win or sweeps
 * @return object contains gameID, picks, conf, result_text, date_issued_short, date_issued_long, if type is instant win, also win_level, game_is_winner, and result
 */
- (NSDictionary*) formatGameData:(NSDictionary*)serverData gameType:(NSString*)gameType {

    NSMutableDictionary *gameHistory = [[NSMutableDictionary alloc] initWithDictionary:serverData];
    
    [gameHistory removeObjectForKey:@"date_issued_long"];
    [gameHistory removeObjectForKey:@"date_issued_short"];
    [gameHistory removeObjectForKey:@"comdata"];
    [gameHistory removeObjectForKey:@"rng_draw"];
    [gameHistory removeObjectForKey:@"max_win_level"];
    [gameHistory removeObjectForKey:@"maxlevel"];
    [gameHistory removeObjectForKey:@"min_win_level"];
    [gameHistory removeObjectForKey:@"minlevel"];
    [gameHistory removeObjectForKey:@"num_choose"];
    [gameHistory removeObjectForKey:@"date_issued"];
    [gameHistory removeObjectForKey:@"pin"];
    [gameHistory removeObjectForKey:@"pin1"];
    [gameHistory removeObjectForKey:@"score"];
    [gameHistory removeObjectForKey:@"numpicks"];
    [gameHistory removeObjectForKey:@"winlevel"];
    
    if ([gameType isEqualToString:@"sweeps"]) {
        [gameHistory removeObjectForKey:@"win_level"];
        [gameHistory removeObjectForKey:@"game_is_winner"];
        if ([serverData objectForKey:@"result"]) {
            [gameHistory setObject:@"entered" forKey:@"result_text"];
            [gameHistory removeObjectForKey:@"result"];
        }
    } else if ([gameType isEqualToString:@"instant"]) {
        if ([[serverData objectForKey:@"game_is_winner"] intValue] == 0) {
            if ([serverData objectForKey:@"result_text"] == [NSNull null]) {
                [gameHistory setObject:@"loss" forKey:@"result_text"];
            }
        
            
        }
    }
    return gameHistory;
}

#pragma mark - peHTTPClientDelegate methods

- (void)actionCompletedWithErrors:(NSArray *)errors response:(NSDictionary*)responseJSON  {
    [self.delegate actionCompletedWithErrors:errors response:responseJSON];
}

- (void)actionCompleted:(NSDictionary*)responseJSON  {
    
    if ([responseJSON objectForKey:@"auth"] != [NSNull null]) {
        if ([[[responseJSON objectForKey:@"auth"] valueForKey:@"success"] intValue] == 1) {
            [self setIsAuthenticated:YES];
            [self setProfileData:[responseJSON objectForKey:@"user_profile"]];
        } else {
            [self setIsAuthenticated:NO];
        }
    }
    
    if ([[[responseJSON objectForKey:@"result"] valueForKey:@"success"] intValue] == 1) {
        [self.delegate actionCompleted:responseJSON];
    } else{
        
    }

}

/*
#pragma mark - Error Methods

- (void) newErrorWithNLS:nls code:(int)code action:(NSString*)action {
    
}
- (BOOL) hasErrors {
    if ([[peError errorManager] getErrorCount] > 0) {
        return YES;
    }
    return NO;
}

- (NSError*) getLastError {
    return [[peError errorManager] getLastError];
}
- (NSArray*) getAllErrors {
    return [[peError errorManager] getErrors];
}

- (NSArray*) getAllErrorsString {
    return [[peError errorManager] getErrorsString];
}
- (void) flushErrors {
    [[peError errorManager] flushErrors];
}
*/

@end