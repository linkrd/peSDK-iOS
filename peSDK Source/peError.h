//
//  peError.h
//  peSDK iOS
//
//  Created by Thieu Huynh on 2013-04-24.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface peError : NSObject {
    NSMutableArray *errors;
}

+ (peError *) errorManager;
- (void) setErrorWithNls:(NSString*)nls action:(NSString*)action code:(int)error_code;
- (void) addError:(NSError*)nserror action:(NSString*)action code:(int)error_code;
- (NSString*) getErrorString:(NSString*)nls table:(NSString*)table comment:(NSString*)comment;
- (NSString*) getErrorString:(NSString*)nls table:(NSString*)table;
- (NSString*) getErrorString:(NSString*)nls;
- (int) getErrorCount;
- (NSError *) getLastError;
- (NSArray *) getErrors;
- (NSArray *) getErrorsString;
- (void) flushErrors;
+ (NSError*) createNSErrorWithNLS:(NSString*)nls action:(NSString*)action code:(NSInteger)code;
- (void) createNSErrorWithArray:(NSArray*)nlsArray action:(NSString*)action code:(NSInteger)code;

@end
