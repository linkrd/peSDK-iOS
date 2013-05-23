//
//  historyViewController.m
//  peSDK Sample
//
//  Created by Thieu Huynh on 2013-05-13.
//  Copyright (c) 2013 SCA interactive. All rights reserved.
//

#import "historyViewController.h"


@interface historyViewController ()

@end

@implementation historyViewController {
@private
    __strong UIActivityIndicatorView *_activityIndicatorView;
}


@synthesize prizeSDK, historyTableView, historyArray, itemsList;


-(void)loadView{
    
    historyTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    historyTableView.delegate = self;
    historyTableView.dataSource = self;
    
    historyTableView.autoresizesSubviews = YES;
    
    itemsList = [[NSMutableArray alloc] init];
    
    [itemsList addObject:@"Sunday"];
    [itemsList addObject:@"MonDay"];
    [itemsList addObject:@"TuesDay"];
    [itemsList addObject:@"WednesDay"];
    [itemsList addObject:@"ThusDay"];
    [itemsList addObject:@"FriDay"];
    [itemsList addObject:@"SaturDay"];
    
    [self.navigationController pushViewController:self animated:YES];
    self.navigationItem.title = @"Day List";
    
    self.view = historyTableView;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
	[_activityIndicatorView startAnimating];
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"uniqueIDfgdfHERE", peContestAdminIDKey,
                              @"demosdk", peClientKey,
                              @"instant", pePromoKey,
                              @"DEMO-SDK1-1234-5678", peConfigAuthKey, nil];
    
    NSLog(@"%@", settings);
    
    @try {
        prizeSDK = [[peSDK alloc] initWithSettings:settings delegate:self];
    }
    @catch (NSException* e) {
        NSLog(@"peSDK NSException:%@", e);
    }
}

- (void)configCompleted:(NSDictionary *) configJSON  {
    
    NSLog(@"configcomplete: %@", configJSON);
    //[_activityIndicatorView stopAnimating];
    
    NSDictionary * config = [[configJSON objectForKey:@"result"] objectForKey:@"config"];
    [[peConfig sharedConfig] initWithConfig:config];
    
    NSError *error = nil;
    NSDictionary* authparams = [[NSDictionary alloc] initWithObjectsAndKeys:@"tayo", @"username", nil];
    if ([prizeSDK authenticateOnServer: authparams]){
        NSLog(@"authenticateOnServerWithParams");
    } else {
        NSLog(@"authenticateOnServerWithParams NO");
    }
    
    [prizeSDK buildAndSend:@"gamehistory" params:authparams error:&error];
    if(error){
        NSLog(@"gamehistory:%@", error);
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    }
}

- (void)configCompletedWithErrors:(NSArray *)errors response:(NSDictionary*)responseJSON  {
    //[_activityIndicatorView stopAnimating];
    NSString *errorString = [[NSString alloc] initWithString:NSLocalizedStringFromTable([errors lastObject], peNLSFile, @"peSDk error")];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"peSDK Configuration Error", nil) message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    
}

- (void)actionCompletedWithErrors:(NSArray *)errors response:(NSDictionary*)responseJSON  {
    NSString *action = [[NSString alloc] initWithString:[[responseJSON objectForKey:@"result"] valueForKey:@"action"]];
    NSLog(@"action:%@ errors:%@ response:%@", action, errors, responseJSON);
    [_activityIndicatorView stopAnimating];
    NSString *errorString = [[NSString alloc] initWithString:NSLocalizedStringFromTable([errors lastObject], peNLSFile, @"peSDk error")];
    if ([action isEqualToString:@"gamehistory"]) {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil) message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"peSDK Configuration Error", nil) message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    }
}

- (void)actionCompleted:(NSDictionary*)responseJSON  {
    NSString *action = [[NSString alloc] initWithString:[[responseJSON objectForKey:@"result"] valueForKey:@"action"]];
    NSLog(@"action:%@ response:%@", action, responseJSON);
    
    if ([action isEqualToString:@"gamehistory"]) {
        historyArray = [[NSArray alloc] initWithArray:[[responseJSON objectForKey:@"result"] valueForKey:@"history"]];
        NSLog(@"gamehistory:%@", historyArray);
        historyTableView.delegate = self;
        historyTableView.dataSource = self;
        [historyTableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"------------------------------------count:%d", [historyArray count]);
    return [historyArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    }
    
    // Set up the cell...
    NSString *cellValue = [[NSString alloc] initWithFormat:@"GameID:%@ win level:%@", [[historyArray objectAtIndex:indexPath.row] objectForKey:@"gameID"], [[historyArray objectAtIndex:indexPath.row] objectForKey:@"win_level"]];
    NSLog(@"------------------------------------cellValue:%@", cellValue);
    cell.textLabel.text = cellValue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *selectDay = [NSString stringWithFormat:@"%d", indexPath.row];
    
    //TableDetailViewController *tbvController = [[TableDetailViewController alloc] initWithNibName:@"TableDetailViewController" bundle:[NSBundle mainBundle]];
    NSString *text = [[NSString alloc] initWithFormat:@"%@", [historyArray objectAtIndex:indexPath.row] ];
    //tbvController.textView.text = text;
    NSLog(@"index:%@ %@", selectDay, text);
    //[self.navigationController pushViewController:tbvController animated:YES];
   // self.view = self.navigationController.view;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
