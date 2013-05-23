//
//  DetailViewController.m
//  peSDK Sample
//
//  Created by Thieu Huynh on 2013-05-13.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Detail";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)HistoryTableViewController: (HistoryTableViewController *)controller didSelectHistory:(NSString *)gameID {
    NSLog(@"didSelectHistory");
    
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"prepareForSegue:%@", segue.identifier );
	if ([segue.identifier isEqualToString:@"PickGame"]) {
		
	}
}

@end
