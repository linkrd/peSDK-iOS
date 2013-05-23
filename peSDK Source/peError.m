//
//  peError.m
//  peSDK iOS
//
//  Created by Thieu Huynh on 2013-04-24.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import "peError.h"
#import "peSDK.h"

@implementation peError

+ (peError *) errorManager {
    
    static peError *_errorManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _errorManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:peAPIBaseUrlString]];
    });
    
    return _errorManager;
}

- (void) setErrorWithNls:(NSString*)nls action:(NSString*)action code:(int)error_code {
    
    NSError *error = [peError createNSErrorWithNLS:nls action:action code:error_code];
    
    [errors addObject:error];
    
    switch (error_code) {
        case pe_REQUEST_ERROR:
            break;
        case pe_CONFIG_ERROR:
            //throw exception
            [NSException raise:@"peSDK Config Exception" format:@"Set error with NLS: %@", [self getErrorString:nls]];
            break;
        case pe_DATA_ERROR:
        case pe_API_ERROR:
        case pe_RESULT_ERROR:
        default:
            break;
    }
}

- (void) addError:(NSError*)nserror action:(NSString*)action code:(int)code {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:[nserror localizedDescription] forKey:NSLocalizedDescriptionKey];
    [errorDetail setValue:action forKey:@"peAction"];
    [errors addObject:[NSError errorWithDomain:peSDKErrorDomain code:code userInfo:errorDetail]];
    
}

- (NSString *) getErrorString:(NSString*)nls table:(NSString*)table comment:(NSString*)comment {
    if (table == nil) {
        table = peNLSFile;
    }
    return [NSString stringWithFormat:NSLocalizedStringFromTable(nls, table, comment)];
}

- (NSString *) getErrorString:(NSString*)nls table:(NSString*)table {
    return [NSString stringWithFormat:NSLocalizedStringFromTable(nls, table, nil)];
}

- (NSString *) getErrorString:(NSString*)nls {
    return [NSString stringWithFormat:NSLocalizedStringFromTable(nls, nil, nil)];
}

-(void) logErrors {
    
}

- (int) getErrorCount {
    return [errors count];
}

- (NSArray *) getErrors {
    return errors;
}

- (NSArray *) getErrorsString {
    NSMutableArray *NSErrors = [[NSMutableArray alloc] init];
    for (id err in errors) {
        [NSErrors addObject:[err localizedDescription]];
    }
    return NSErrors;
}

- (NSError *) getLastError {
    return [errors lastObject];
}

- (void) flushErrors {
    errors = nil;
}

+ (NSError*) createNSErrorWithNLS:(NSString*)nls action:(NSString*)action code:(NSInteger)code {
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:[[NSString alloc] initWithString:NSLocalizedStringFromTable(nls, peNLSFile, @"peSDk error")] forKey:NSLocalizedDescriptionKey];
    [errorDetail setValue:action forKey:@"peAction"];
    [errorDetail setValue:nls forKey:peNLSFile];
    return [NSError errorWithDomain:peSDKErrorDomain code:code userInfo:errorDetail];
}

- (void) createNSErrorWithArray:(NSArray*)nlsArray action:(NSString*)action code:(NSInteger)code {
    for (id nls in nlsArray) {
        [errors addObject:[peError createNSErrorWithNLS:nls action:action code:code]];
    }
}
@end

