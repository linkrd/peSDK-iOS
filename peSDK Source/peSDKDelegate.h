//
//  peSDKDelegate.h
//  peSDK iOS
//
//  Created by Thieu Huynh on 2013-05-16.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//


@protocol peSDKDelegate <NSObject>

- (void)actionCompleted:(NSDictionary*)responseJSON;
- (void)actionCompletedWithErrors:(NSArray*)errors response:(NSDictionary*)responseJSON;

@end
