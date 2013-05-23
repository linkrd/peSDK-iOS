//
//  HistoryTableViewController.h
//  peSDK Sample
//
//  Created by Thieu Huynh on 2013-05-13.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "peSDK.h"

@class HistoryTableViewController;

@protocol HistoryTableViewControllerDelegate <NSObject>
- (void)HistoryTableViewController: (HistoryTableViewController *)controller didSelectHistory:(NSString *)gameID;
@end

@interface HistoryTableViewController : UITableViewController <peSDKDelegate,UITableViewDelegate,UITableViewDataSource>{
    
}

@property (nonatomic, weak) id <HistoryTableViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITableView *historyTable;
@property (strong, nonatomic) peSDK *prizeSDK;
@property (strong, nonatomic) NSArray *historyArray;
@end
