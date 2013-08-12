SCAi PrizeSDK iOS
=================

About the SDK
-------------

SCAi PrizeSDK iOS can facilitate adding sweepstakes or instant win functionality to a new or existing iOS app. By integrating the SDK in to your user system, you can give your users the opportunity to win prizes through SCAi's game engine. SCAi's game engine can manage the business rules, such as plays per day, per user and maximum plays for a promotion.

Configuration
-------------

Your sales representative will provide you with the following values:

  * client
  * promo
  * authkey

Set these values in your configuration settings variable, and initialize the class object with the settings. In the case of a configuration error, an exception is thrown.


Demo Configurations
-------------------

### Sweeps:
```objectivec
    NSString *udid = @"any-unique-string";
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              udid, peContestAdminIDKey,
                              @"demosdk", peClientKey,
                              @"sweeps", pePromoKey,
                              @"DEMO-SDK1-1234-5678", peConfigAuthKey, nil];
```                                            
### Instant Win (one level):
```objectivec
    NSString *udid = @"any-unique-string";
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              udid, peContestAdminIDKey,
                              @"demosdk", peClientKey,
                              @"instant", pePromoKey,
                              @"DEMO-SDK1-1234-5678", peConfigAuthKey, nil];
```                        
### Instant Win (multi level):
```objectivec
    NSString *udid = @"any-unique-string";
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              udid, peContestAdminIDKey,
                              @"demosdk", peClientKey,
                              @"instantmulti", pePromoKey,
                              @"DEMO-SDK1-1234-5678", peConfigAuthKey, nil];
```                              
                                              
Sample Code
-----------

A sample Xcode project is provided. At a minimum, the SDK requires a username. Depending on your own user system, the business rules of the promotion and the rules required by the prizing contest, you may be required to provide more than a username. The SDK is meant to integrate with a user on your own system. This value must maintain consistency throughout the promotions. If you do not use a login or screen name or your login name does not comply with our system rules (under 25 chars and alphanumeric: 'a-z' '0-9' '-' and '_') or you allow users to change their screen name, you may use your userID as a username or the database index of the user's record. If your promotion does not require business rules regarding plays per user, you may use microtime or another sufficiently unique value for each play.
Please create your own test users to use with the examples provided. 

For the demos, one username, 'demo_infinite_plays' is permitted infinite plays. If you wish to test using this username, be aware, it does not behave like a regular user, and will not be restricted by the rules regarding plays per day. You should test with the user scheme you intend to use in your application.

The user data is shared between any promotions at a 'client' level, so any users you create and set the profile of, in demosdk-instant will have the same profile data in demosdk-sweeps. When you are ready for your promotion(s) to be set up, we will give you a new 'client' ID and none of the test users will exist in that configuration.

###User fields, types and lengths:

     
| Name          | Type          | Length | Default  |
| ------------- |:-------------:|:------:| :------: |
| username      | varchar       | 25     | NOT NULL |
| firstname     | varchar       | 25     | NULL     |
| lastname      | varchar       | 25     | NULL     |
| address       | varchar       | 50     | NULL     |
| address2      | varchar       | 50     | NULL     |
| city          | varchar       | 30     | NULL     |
| state         | varchar       | 25     | NULL     |
| country       | varchar       | 30     | NULL     |
| zip           | varchar       | 12     | NULL     |
| birthdate     | smalldatetime | 25     | NULL     |
| gender        | varchar       | 1      | NULL     |
| title         | varchar       | 100    | NULL     |
| company       | varchar       | 80     | NULL     |
| day_phone     | varchar       | 20     | NULL     |
| evening_phone | varchar       | 20     | NULL     |
| fax_phone     | varchar       | 20     | NULL     |
| mobile_email  | varchar       | 75     | NULL     |
| alt_email     | varchar       | 75     | NULL     |
| answer1       | varchar       | 50     | NULL     |
| answer2       | varchar       | 50     | NULL     |
| answer3       | varchar       | 50     | NULL     |
| answer4       | varchar       | 50     | NULL     |
| answer5       | varchar       | 50     | NULL     |
| answer6       | varchar       | 50     | NULL     |
| answer7       | varchar       | 50     | NULL     |
| answer8       | varchar       | 50     | NULL     |
| answer9       | varchar       | 50     | NULL     |
| answer10      | varchar       | 50     | NULL     |





PrizeSDK Functions
------------------

###Class Constructor

####new PrizeSDK 

Creates a new SDK object. 
```objectivec
    NSString *udid = @"any-unique-string";
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              udid, peContestAdminIDKey,
                              @"demosdk", peClientKey,
                              @"sweeps", pePromoKey,
                              @"DEMO-SDK1-1234-5678", peConfigAuthKey, nil];
                              
    @try {
        prizeSDK = [[peSDK alloc] initWithSettings:settings delegate:self];
    }
    @catch (NSException* e) {
        NSLog(@"peSDK NSException:%@", e);
    }
``` 
  
> params: an array containing the configuration values
>
> returns: [object] a PrizeSDK class object
>
> errors: throws an exception


###Configuration Data

* #### isOpen 
  Checks whether or not the contest is open.
  
  usage: `[prizeSDK isOpen];`

  > returns:[`BOOL`] `YES` if contest is currently open. `NO` for closed.


* #### getRequiredFields
  Get the required fields from the configuration values .

  usage: `[prizeSDK getRequiredFields];`
    
  > returns: [`NSDictionary`] list of required fields


* #### getAllFields
  Get all possible profile fields from the configuration values.

  usage: `[prizeSDK getAllFields];`
    
  > returns: [`NSDictionary`] list of all fields available


* #### getPrizingInfo
  Gets the number of prize levels and the minimum and maximum level for instan win contest

  usage: `[prizeSDK getPrizingInfo];`

  > returns: [`NSDictionary`] list including number of prize levels and the min and max for instant win or `nil` for sweeps.


### User Profile Functions

For any of the following functions which require the user parameters, you may leave the parameters blank if the user information is already in place. Only the first call requiring the user's information requires the user parameters. User parameters are key/value pairs.

* #### isAuthenticated 
  Check if a user has been authenticated by the server.

  usage: `[prizeSDK isAuthenticated];`
  
  > returns: [`BOOL`] `YES` if a user is authenticated, otherwise `NO`

* #### setUserParams 
  Sets the user paramater array, but does not check the values.

  usage: `[prizeSDK setUserParams:userParameters];`
   
  > params: 
  >  * `userParameters` - set the user parameter dictionary

* #### authenticateOnServer 
  Authenticates the user on the server

  usage: 
  ```objectivec
  NSError *error = nil;
  [prizeSDK authenticateOnServer:userParameters error:&error];
  ```
  
  > params: 
  >  * `userParameters` - if not already set, a user parameter array containing at minimum, all required fields
  >  * `error` - pointer to `NSError`
  >
  > returns:[`BOOL`] `YES` if user is sucessfully authenticated
  

* #### getCurrentProfileParams 
  Returns the current parameters in the user's profile as key value pairs

  usage: `[prizeSDK getCurrentProfileParams];`
  
  > returns: [`NSDictionary`] keys and values currently set in the user's profiles


* #### getUserProfile 
  Returns the current user profile object with all possible profile fields and their current values

  usage: `[prizeSDK getUserProfile];`
  
  > params: 
  >  * `userParameters` - if not already set, a user parameter array containing at minimum, all required fields
  >
  > returns: [`NSDictionary`] fields after server update, each field with name, value, and is_required
 

* #### setUserProfile 
  Updates or sets the User Profile on the server.

  usage: 
  ```objectivec
  NSError *error = nil;
  [prizeSDK setUserProfile:userParameters error:&error];
  
  if(error){
      //errror setting params
  } else {
      //successful setting params
  }
  ```
  
  > params: 
  >  * `userParameters` - if not already set, a user parameter array containing at minimum, all required fields
  >  * `error` - pointer to `NSError`
  >
  > returns: [`NSDictionary`] fields after server update, each field with name, value, and is_required
 

### Entries and Plays Functions

* #### canEnter 
  Checks to see if the user is currently permitted to play / enter (use either canEnter or nextPlay - not both)

  usage: `[prizeSDK canPlay:userParameters error:&error];`
  
  > params: 
  >  * `userParameters` - if not already set, a user parameter array containing at minimum, all required fields
  >  * `error` - pointer to `NSError`
  >
  > returns: [`BOOL`] returns YES if the user is allowed to play


* #### nextPlay 
  Checks when the user can play next. (use either canEnter or nextPlay - not both) 

  usage: `prizeSDK nextPlay:userParameters error:&error];`
  
  > params: 
  >  * `userParameters` - if not already set, a user parameter array containing at minimum, all required fields
  >  * `error` - pointer to `NSError`
  >
  > returns: Formatted date of when a user can play next. '0' in the case that a user can play now.


* #### enterSweeps 
  Enter the sweepstakes

  usage: `[prizeSDK enterSweeps:userParameters error:&error];`
  
  > params: 
  >  * `userParameters` - if not already set, a user parameter array containing at minimum, all required fields
  >  * `error` - pointer to `NSError`
  >
  > returns: [`NSDictionary`] A game object array containing gameID, result_text and other values


* #### enterInstantWin 
  Enter instant win

  usage: `[prizeSDK enterInstantWin:userParameters error:&error];`
  
  > params: 
  >  * `userParameters` - if not already set, a user parameter array containing at minimum, all required fields
  >  * `error` - pointer to `NSError`
  >
  > returns: [`NSDictionary`] A game object array containing gameID, result_text and other values
 

* #### buildAndSend 
  This method allows you to make an asynschronous call to the server with a specific action. It's the base method of peSDK. ViewController that instantiate peSDK will have to implement the `peSDKDelegate` and filter the response by the action string.

 `@interface HistoryTableViewController : UITableViewController <peSDKDelegate,UITableViewDelegate,UITableViewDataSource>`

  Possible actions are: 
     * `getconfig` - get contest configuration from server, this is called when peSDK is instantiated 
     * `auth_only` - check server authentication for `username`
     * `canplay` - check if a `username` can play the contest
     * `updateprofile` - update `username` fields
     * `gamehistory` -  get the game history for a specific `username`
     * `instantwin` - get a game result form the server

  usage: 
  
    ```objectivec

    - (void) viewWillAppear:(BOOL)animated {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        prizeSDK.delegate = self;
        NSError *error = nil;
        
        [prizeSDK buildAndSend:@"gamehistory" params:nil error:&error];
        
        if(error){
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        }
    }
  
    
    - (void)actionCompleted:(NSDictionary*)responseJSON  {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *action = [[NSString alloc] initWithString:[[responseJSON objectForKey:@"result"] valueForKey:@"action"]];
            
        if ([action isEqualToString:@"gamehistory"]) {
            historyArray = [[NSArray alloc] initWithArray:[[responseJSON objectForKey:@"result"] valueForKey:@"history"]];
            NSArray *formatArray = [prizeSDK gameHistoryData:historyArray];
            historyArray = [[NSArray alloc] initWithArray:formatArray];
            historyTable.delegate = self;
            historyTable.dataSource = self;
            [historyTable reloadData];
        }
    }
    ```
     > params: 
     >  * `userParameters` - if not already set, a user parameter array containing at minimum, all required fields
     >  * `error` - pointer to `NSError`
     >
     > returns: [`NSArray`] An array of game object arrays containing gameID, result_text and other values
 

### Other Classes

* peHTTPClient: wrapper for request model. Formats data for the request to the server.
* peConfig: fetches, caches and evaluates configuration variables for a promotion.
* peConstants: peSDK iOS constant variables.
* peError: manages error levels and exceptions.

Multilingual games can be done using the localized peNLS.string file.

## Contact

Feel free to contact me if you have any questions.

[Thieu Huynh](http://github.com/ThieuHuynh)
