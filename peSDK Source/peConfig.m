//
//  peConfig.m
//  peSDK iOS
//
//  Created by Thieu Huynh on 2013-04-18.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

/**
 *  peConfig
 *
 *
 *
 *
 */
#import "peConfig.h"
#import "peConstants.h"

@implementation peConfig

@synthesize configuration, params;

+ (peConfig *) sharedConfig {
    
    static peConfig *_sharedConfig = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedConfig = [[self alloc] init];
    });
    
    return _sharedConfig;
}

- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}

/**
 *  Initialize contest configuration
 *
 *  @param _config NSDictionary contest configuration
 */
- (void) initWithConfig:(NSDictionary*)_config {
    configuration = _config;
    
    // implement caching?
}

/**
 *  Tell you if the contest type is an instant win contest
 *
 *  @return BOOL is an instant win contest
 */
- (BOOL) isInstantWin {
    if ([[configuration valueForKey:@"game_type"] isEqualToString:@"instantwin"]) {
        return YES;
    }
    return NO;
}

/**
 *  Tell you if the contest type is a sweepstake contest
 *
 *  @return BOOL is a sweepstake contest
 */
- (BOOL) isSweeps {
    if ([[configuration valueForKey:@"game_type"] isEqualToString:@"sweeps"]) {
        return YES;
    }
    return NO;
}

/**
 *  Tell you if the contest can be played
 *
 *  @return boolean contest is open
 */
- (BOOL) isOpen {
    if ([[configuration valueForKey:@"is_open"] intValue] == 1) {
        return YES;
    }
    return NO;
}

/**
 *  Get period entry information
 *
 *  @return NSDictionary period entry information
 */
- (NSDictionary*) getEntryPeriod {
    NSMutableDictionary *playPeriod = [[NSMutableDictionary alloc] initWithDictionary:[configuration valueForKey:@"user_play_period"]];
    [playPeriod setValue:[configuration valueForKey:@"open_unixtime"] forKey:@"open_unixtime"];
    [playPeriod setValue:[configuration valueForKey:@"close_unixtime"] forKey:@"close_unixtime"];
    [playPeriod setValue:[configuration valueForKey:@"is_open"] forKey:@"is_open"];
    [playPeriod setValue:[configuration valueForKey:@"open_date"] forKey:@"open_date"];
    [playPeriod setValue:[configuration valueForKey:@"close_date"] forKey:@"close_date"];
    [playPeriod setValue:[configuration valueForKey:@"time_zone"] forKey:@"time_zone"];
    
    return playPeriod;
}

/**
 *  Get prize information from configuration
 *
 *  @return NSDictionary prize information
 */
- (NSDictionary*) getPrizingInfo {
    if ([[configuration valueForKey:@"game_type"] isEqualToString:@"instantwin"]) {
        return [configuration valueForKey:@"prizing"];
    } 
    return nil;
}

/**
 *  Get profile fields from configuration
 *
 *  @return NSDictionary profile fields
 */
- (NSDictionary*) getProfileFields {
    NSArray *fields = [[NSArray alloc] initWithArray:[configuration valueForKey:peProfileFieldsKey]];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (id obj in fields) {
        [dict setObject:obj forKey:[obj valueForKey:@"name"]];
    }
    return dict;
}

/**
 *  get count from configuration
 *
 *  @return NSString count
 */
- (NSString*) getCount {
    return [configuration valueForKey:@"count"];
}


/**
 *  getRequiredFields 
 *
 *  @return NSDictionary required fields
 */
- (NSDictionary*) getRequiredFields {
    
    NSMutableDictionary *required = [[NSMutableDictionary alloc] init];
    NSDictionary *profileFields = [self getProfileFields];
    NSArray *keys = [[self getProfileFields] allKeys];
    for (id key in keys) {
        if ([[[profileFields valueForKey:key] valueForKey:@"is_required"] intValue] == 1) {
            [required setObject:[profileFields valueForKey:key] forKey:key];
        }

    }
    return required;
}


/**
 *  Get all fields
 *
 *  @return NSDictionary all fields
 */
- (NSDictionary*) getAllFields {
    
    NSMutableDictionary *fields = [[NSMutableDictionary alloc] init];
    NSDictionary *profileFields = [self getProfileFields];
    NSArray *keys = [[self getProfileFields] allKeys];
    for (id key in keys) {
        [fields setObject:[profileFields valueForKey:key] forKey:key];
    }
    return fields;
}

/**
 *  Get required field names
 *
 *  @return NSString required field names
 */
- (NSString*) getRequiredFieldNames {
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    NSDictionary *profileFields = [self getProfileFields];
    NSArray *keys = [[self getProfileFields] allKeys];
    for (id key in keys) {
        if ([[[profileFields valueForKey:key] valueForKey:@"is_required"] intValue] == 1 && ![[[profileFields valueForKey:key] valueForKey:@"name"] isEqual:@"auth"] ) {
            [fields addObject:[[profileFields valueForKey:key] valueForKey:@"name"]];
        }
    }
    return [fields componentsJoinedByString:@","];
}

/**
 *  getAllFieldNames
 *
 *  @return NSString all field names
 */
- (NSString*) getAllFieldNames {
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    NSDictionary *profileFields = [self getProfileFields];
    NSArray *keys = [[self getProfileFields] allKeys];
    for (id key in keys) {
        if (![[[profileFields valueForKey:key] valueForKey:@"name"] isEqual:@"auth"] ) {
            [fields addObject:[[profileFields valueForKey:key] valueForKey:@"name"]];
        }
    }
    return [fields componentsJoinedByString:@","];
}

/**
 *  getAuthUserField
 *
 *  @return NSString user_auth_field 
 */
- (NSString*) getAuthUserField {
    return [configuration valueForKey:@"user_auth_field"];
}

/**
 *  hasRequiredFields
 *
 *  @param parameters NSDictionary fields to check
 *  @return BOOL has required fields
 */
- (BOOL) hasRequiredFields:(NSDictionary*) parameters {
    NSDictionary *profileFields = [self getProfileFields];
    NSArray *keys = [[self getProfileFields] allKeys];
    for (id key in keys) {
        NSString *keyName = [[profileFields valueForKey:key] valueForKey:@"name"];
        if ([[[profileFields valueForKey:key] valueForKey:@"is_required"] intValue] == 1 ) {
            if ((![parameters valueForKey:keyName] || [[parameters valueForKey:keyName] isEqualToString:@""]) && ![keyName isEqualToString:@"auth"]) {
                return NO;
            }
        }
    }
    return YES;
}

/**
 *  get the whole configuration
 *
 *  @return NSDictionary contest configuration
 */
- (NSDictionary*) getAll {
    return configuration;
}

@end
