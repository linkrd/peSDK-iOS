//
//  DetailViewController.h
//  peSDK Sample
//
//  Created by Thieu Huynh on 2013-05-13.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryTableViewController.h"

@interface DetailViewController : UIViewController <HistoryTableViewControllerDelegate> {
    UITextView *textView;
}

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, weak) id <HistoryTableViewControllerDelegate> delegate;
@end
