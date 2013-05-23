//
//  peConfig.h
//  peSDK iOS
//
//  Created by Thieu Huynh on 2013-04-18.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//


/**
 * peConfig handles contest configuration
 *
 *
 *
 *
 */

#import <Foundation/Foundation.h>

@interface peConfig : NSObject {
    NSDictionary *params;
    NSDictionary *configuration;
}

@property (nonatomic, strong) NSDictionary *configuration;
@property (nonatomic, strong) NSDictionary *params;
+ (peConfig *) sharedConfig;
- (void) initWithConfig:(NSDictionary*)config;
- (BOOL) isInstantWin;
- (BOOL) isSweeps;
- (BOOL) isOpen;
- (NSDictionary*) getEntryPeriod;
- (NSDictionary*) getPrizingInfo;
- (NSDictionary*) getProfileFields;
- (NSString*) getCount;
- (NSDictionary*) getRequiredFields;
- (NSDictionary*) getAllFields;
- (NSString*) getRequiredFieldNames;
- (NSString*) getAllFieldNames;
- (NSString*) getAuthUserField;
- (BOOL) hasRequiredFields:(NSDictionary*) params;
- (NSDictionary*) getAll;
@end
