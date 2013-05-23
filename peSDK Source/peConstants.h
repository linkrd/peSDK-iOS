//
//  peConstants.h
//  peSDK iOS
//
//  Created by Thieu Huynh on 2013-04-19.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 *  peConstant contains static variables
 *
 */


/** peSDK Error Codes */
typedef NS_ENUM(NSInteger, peSDKErrorCode) {
    /* data from server is wrong */
    pe_REQUEST_ERROR = 1600,
    /* data from server is wrong */
    pe_CONFIG_ERROR,
    /* data from server is wrong */
    pe_DATA_ERROR,
    /* data doesn't allow play */
    pe_API_ERROR,
    /* result from server is an error */
    pe_RESULT_ERROR
} ;

extern NSString *const peSDKErrorDomain;

extern NSString * const peAPIBaseUrlString;
extern NSString * const peAPIString;
extern NSString * const peRequestMethod;
extern NSString * const peResponseFormat;
extern NSString * const peResponseFormatKey;
extern NSString * const peActionKey;
extern NSString * const peAuthKey;
extern NSString * const peConfigAuthKey;
extern NSString * const peClientKey;
extern NSString * const pePromoKey;
extern NSString * const peContestAdminIDKey;
extern NSString * const peProfileFieldsKey;
extern NSString * const peNLSFile;

@interface peConstants : NSObject

@end
