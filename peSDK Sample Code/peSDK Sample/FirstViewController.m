//
//  FirstViewController.m
//  peSDK Sample
//
//  Created by Thieu Huynh on 2013-05-13.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import "FirstViewController.h"
#import "GameViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "peError.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize prizeSDK, usernameField;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *contestAdminID = @"any-unique-string";
    
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              contestAdminID, peContestAdminIDKey,
                              @"demosdk", peClientKey,
                              @"instant", pePromoKey,
                              @"DEMO-SDK1-1234-5678", peConfigAuthKey, nil];
    
    @try {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        prizeSDK = [[peSDK alloc] initWithSettings:settings delegate:self];
    }
    @catch (NSException* e) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSLog(@"peSDK NSException:%@", e);
    }
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configCompleted:(NSDictionary *) configJSON  {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSDictionary * config = [[configJSON objectForKey:@"result"] objectForKey:@"config"];
    [[peConfig sharedConfig] initWithConfig:config];
       
    if(prizeSDK) {
        GameViewController *gvc = [self.tabBarController.viewControllers objectAtIndex:1];
        gvc.prizeSDK = self.prizeSDK;
        
        UINavigationController *nc = [self.tabBarController.viewControllers objectAtIndex:2];
        HistoryTableViewController *htvc =  [nc.viewControllers objectAtIndex:0];
        htvc.prizeSDK = self.prizeSDK;
    }
}


- (void)actionCompletedWithErrors:(NSArray *)errors response:(NSDictionary*)responseJSON  {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString *action = [[NSString alloc] initWithString:[[responseJSON objectForKey:@"result"] valueForKey:@"action"]];
    NSLog(@"action:%@ errors:%@ response:%@", action, errors, responseJSON);
    NSString *errorString = [[NSString alloc] initWithString:NSLocalizedStringFromTable([errors lastObject], peNLSFile, @"peSDk error")];
    if ([action isEqualToString:@"getconfig"]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"peSDK Configuration Error", nil) message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        [NSException raise:@"peSDK Config Exception" format:@"%@", errorString];
    } else {
        NSLog(@"action with errror '%@' not handled by actionCompleted delegate", action);
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"peSDK Configuration Error", nil) message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    }
}

- (void)actionCompleted:(NSDictionary*)responseJSON  {
    NSString *action = [[NSString alloc] initWithString:[[responseJSON objectForKey:@"result"] valueForKey:@"action"]];
    NSLog(@"action:%@ response:%@", action, responseJSON);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if ([[[responseJSON objectForKey:@"result"] valueForKey:@"success"] intValue] == 1) {
        if ([action isEqualToString:@"getconfig"]) {
            [self configCompleted:responseJSON];
        } else{
            NSLog(@"action '%@' not handled by actionCompleted delegate", action);
        }
    } else{
        NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[responseJSON objectForKey:@"result"]];
        NSArray *errorArray = [[NSArray alloc] initWithArray:[result objectForKey:@"errors"]];
        NSError *error = [peError createNSErrorWithNLS:[errorArray lastObject] action:action code:pe_API_ERROR];
        NSLog(@"actionCompleted Error:%@", error);
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    }
   
}

- (IBAction)clickedLogin:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.view endEditing:YES];
    
    NSDictionary* authparams = [[NSDictionary alloc] initWithObjectsAndKeys:usernameField.text, @"username", nil];
    
    NSError *error = nil;
    
    [prizeSDK authenticateOnServer:authparams error:&error];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if(error){
        NSLog(@"authenticateOnServer:%@", error);
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentication Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    } else {
        
    }
    
}
@end
