//
//  GameViewController.h
//  peSDK Sample
//
//  Created by Thieu Huynh on 2013-05-22.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "peSDK.h"

@interface GameViewController : UIViewController <peSDKDelegate> {
    
}
- (IBAction)checkInstantWin:(id)sender;

@property (nonatomic, strong) peSDK *prizeSDK;
@property (weak, nonatomic) IBOutlet UIButton *clickToWin;
@property (weak, nonatomic) IBOutlet UILabel *headerText;
@property (weak, nonatomic) IBOutlet UITextView *bodyText;
@property (weak, nonatomic) IBOutlet UILabel *username;

@end
