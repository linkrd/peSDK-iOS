//
//  HistoryTableViewController.m
//  peSDK Sample
//
//  Created by Thieu Huynh on 2013-05-13.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "DetailViewController.h"

@interface HistoryTableViewController ()

@end

@implementation HistoryTableViewController {
@private
    __strong UIActivityIndicatorView *_activityIndicatorView;
}
@synthesize prizeSDK, historyArray, historyTable, delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
   
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void) viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    prizeSDK.delegate = self;
    
    NSError *error = nil;
    
    NSDictionary *userProfile = [prizeSDK getUserProfile];
           
    if (userProfile) {
       
        error = nil;
        [prizeSDK buildAndSend:@"gamehistory" params:nil error:&error];
        if(error){
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSLog(@"gamehistory:%@", error);
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        }
       
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"", nil) message:@"Enter a username on Home tab" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)actionCompletedWithErrors:(NSArray *)errors response:(NSDictionary*)responseJSON  {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *action = [[NSString alloc] initWithString:[[responseJSON objectForKey:@"result"] valueForKey:@"action"]];
    NSLog(@"action:%@ errors:%@ response:%@", action, errors, responseJSON);
    
    NSString *errorString = [[NSString alloc] initWithString:NSLocalizedStringFromTable([errors lastObject], peNLSFile, @"peSDk error")];
    if ([action isEqualToString:@"gamehistory"]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil) message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"peSDK Configuration Error", nil) message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    }
}

- (void)actionCompleted:(NSDictionary*)responseJSON  {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *action = [[NSString alloc] initWithString:[[responseJSON objectForKey:@"result"] valueForKey:@"action"]];
    NSLog(@"action:%@ response:%@", action, responseJSON);
    
    if ([action isEqualToString:@"gamehistory"]) {
        historyArray = [[NSArray alloc] initWithArray:[[responseJSON objectForKey:@"result"] valueForKey:@"history"]];
        NSArray *formatArray = [prizeSDK gameHistoryData:historyArray];
        historyArray = [[NSArray alloc] initWithArray:formatArray];
        historyTable.delegate = self;
        historyTable.dataSource = self;
        [historyTable reloadData];
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [historyArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    }
 
    NSString *cellValue = [[NSString alloc] initWithFormat:@"GameID: %@", [[historyArray objectAtIndex:indexPath.row] objectForKey:@"gameID"]];

    cell.detailTextLabel.text = [[historyArray objectAtIndex:indexPath.row] objectForKey:@"short_date"];
    cell.textLabel.text = cellValue;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *textString = [[NSString alloc] initWithFormat:@"%@", [historyArray objectAtIndex:indexPath.row]];
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    [self.navigationController pushViewController:detailViewController animated:YES];
    detailViewController.title = [[NSString alloc] initWithFormat:@"GameID: %@", [[historyArray objectAtIndex:indexPath.row] objectForKey:@"gameID"]];
    detailViewController.delegate = self.delegate;
    detailViewController.textView.text = textString;
    [self.delegate HistoryTableViewController:self didSelectHistory:textString];
    
}

@end
