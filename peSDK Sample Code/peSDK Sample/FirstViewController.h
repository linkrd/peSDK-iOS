//
//  FirstViewController.h
//  peSDK Sample
//
//  Created by Thieu Huynh on 2013-05-13.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "peSDK.h"
#import "HistoryTableViewController.h"

@interface FirstViewController : UIViewController <peSDKDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UILabel *bodyText;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, strong) peSDK *prizeSDK;

- (IBAction)clickedLogin:(id)sender;
@end
