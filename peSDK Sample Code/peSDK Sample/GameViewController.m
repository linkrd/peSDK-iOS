//
//  GameViewController.m
//  peSDK Sample
//
//  Created by Thieu Huynh on 2013-05-22.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import "GameViewController.h"
#import "peConfig.h"

@implementation GameViewController

@synthesize prizeSDK, clickToWin,  bodyText, headerText, username;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"GameViewController viewDidLaod");
}

- (void) viewWillAppear:(BOOL)animated {
    
    prizeSDK.delegate = self;
    
    clickToWin.hidden = YES;
    bodyText.text = @"";
    headerText.text = @"";
    NSError *error = nil;
    
    if ([prizeSDK isAuthenticated]) {
        
        NSDictionary *userProfile = [prizeSDK getUserProfile];
        username.text = [[NSString alloc] initWithFormat:@"username: %@", [[userProfile objectForKey:@"username"] objectForKey:@"value"]   ];
        
        NSError *canEnterError = nil;
        if ([prizeSDK canEnter:nil error:&canEnterError]) {
            clickToWin.hidden = NO;
            bodyText.text = @"";
            if ([[peConfig sharedConfig] isInstantWin]) {
                headerText.text = @"Click To Win!";
            } else {
                headerText.text = @"Click To Enter!";
            }
        } else {
            if ([[peConfig sharedConfig] isInstantWin]) {
                NSString *canEnterErrorString = [canEnterError localizedDescription];
                NSString *nextPlay = [prizeSDK nextPlay:nil error:&error];
                if (nextPlay) {
                    bodyText.text = [[NSString alloc] initWithFormat:@"%@.\n\nNext play available at %@", canEnterErrorString
                                     , nextPlay];
                } else {
                    bodyText.text = [[NSString alloc] initWithFormat:@"%@", [error localizedDescription]];
                }
                headerText.text = @"Click To Win!";
                //bodyText.text = [[NSString alloc] initWithFormat:@"%@.", [canEnterError localizedDescription]];
            } else {
                headerText.text = @"Already Entered!";
            }
        }
        if(error){
            NSString *canEnterErrorString = [canEnterError localizedDescription];
            NSString *nextPlay = [prizeSDK nextPlay:nil error:&error];
            NSLog(@"viewWillAppear:%@", error);
            if (nextPlay) {
                bodyText.text = [[NSString alloc] initWithFormat:@"%@.\n\nNext play available at %@", canEnterErrorString
                                 , nextPlay];
            } else {
                bodyText.text = [[NSString alloc] initWithFormat:@"%@", [error localizedDescription]];
            }
        }
    } else {
        //bodyText.text = [[NSString alloc] initWithFormat:@"You need to enter a username on the Home tab."];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Enter a username on Home tab" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)configCompletedWithErrors:(NSArray *)errors response:(NSDictionary*)responseJSON  {
    
    NSString *errorString = [[NSString alloc] initWithString:NSLocalizedStringFromTable([errors lastObject], peNLSFile, @"peSDk error")];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"peSDK Configuration Error", nil) message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    
}

- (void)actionCompletedWithErrors:(NSArray *)errors response:(NSDictionary*)responseJSON  {
    NSString *action = [[NSString alloc] initWithString:[[responseJSON objectForKey:@"result"] valueForKey:@"action"]];
    NSLog(@"action:%@ errors:%@ response:%@", action, errors, responseJSON);
    NSString *errorString = [[NSString alloc] initWithString:NSLocalizedStringFromTable([errors lastObject], peNLSFile, @"peSDk error")];
    if ([action isEqualToString:@"instantwin"]) {
        clickToWin.hidden = YES;
        NSError *error = nil;
        NSString *nextPlay = [prizeSDK nextPlay:nil error:&error];
        if(error) {
            NSLog(@"error:%@", error);
        }
        bodyText.text = [[NSString alloc] initWithFormat:@"%@.\n\nNext play available at %@", errorString, nextPlay];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil) message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil) message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    }
}

- (void)actionCompleted:(NSDictionary*)responseJSON  {
    
    NSString *action = [[NSString alloc] initWithString:[[responseJSON objectForKey:@"result"] valueForKey:@"action"]];
    NSLog(@"action:%@ response:%@", action, responseJSON);
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    if ([action isEqualToString:@"instantwin"]) {
        NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[responseJSON objectForKey:@"result"]];
        if ([[[responseJSON objectForKey:@"result"] valueForKey:@"success"] intValue] == 1) {
            
            
            NSLog(@"win_level:%@", [[result objectForKey:@"game"] valueForKey:@"win_level"]);
            
            if([[[result objectForKey:@"game"] valueForKey:@"win_level"] intValue] == 1) {
                headerText.text = @"Congratulations!";
                bodyText.text = @"You are a winner! This is a demo";
            } else{
                headerText.text = @"Sorry";
                bodyText.text = @"Try again tomorrow.";
            }
        } else{
            [errors addObject:[result objectForKey:@"errors"]];
            NSLog(@"errors:%@ result:%@", errors, result);
        }
    } else{
        NSLog(@"action '%@' not handled by actionCompleted delegate", action);
    }
}

- (IBAction)checkInstantWin:(id)sender {
    
    clickToWin.hidden = YES;
    NSError *error = nil;
    
    if ([[peConfig sharedConfig] isInstantWin]) {
        NSDictionary *gameData = [prizeSDK enterInstantWin:nil error:&error];
        
        if([[gameData valueForKey:@"game_is_winner"] intValue] == 1) {
            headerText.text = @"Congratulations!";
            bodyText.text = @"You are a winner! This is a demo";
        } else{
            headerText.text = @"Sorry";
            bodyText.text = @"Try again tomorrow.";
        }
        if(error){
            NSLog(@"instantwin:%@", error);
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        }
    } else {
        NSDictionary *gameData = [prizeSDK enterSweeps:nil error:&error];
        
        NSLog(@"gamedata:%@", gameData);
        if([[gameData valueForKey:@"result_text"] isEqualToString:@"entered"]) {
            bodyText.text = @"You are entered in the sweepstake!";
        } else{
            headerText.text = @"Sorry";
            bodyText.text = @"Try again tomorrow.";
        }
        if(error){
            NSLog(@"instantwin:%@", error);
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        }

    }
    
    
}
@end
