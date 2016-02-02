//
//  HomeController.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/20/08.
//  Copyright 2008 BoonEx. All rights reserved.
//

#import "HomeController.h"
#import "ProfileBlock.h"
#import "BaseUserThumbTableController.h"
#import "MailHomeController.h"
#import "FriendsHomeController.h"
#import "SearchHomeController.h"
#import "StatusMessageController.h"
#import "LocationController.h"
#import "ImagesAlbumsController.h"
#import "VideoAlbumsController.h"
#import "AudioAlbumsController.h"
#import "ProfileInfoController.h"
#import "WebPageController.h"
#import "Designer.h"

#define BX_HOME_BUTTONS_OFFSET_PORTRAIT_IPAD 128.0
#define BX_HOME_BUTTONS_OFFSET_PORTRAIT_IPHONE 80.0

#define BX_HOME_BUTTONS_DX 10.0
#define BX_HOME_BUTTONS_DY 10.0
#define BX_HOME_BUTTONS_DX_IPAD 61.0
#define BX_HOME_BUTTONS_DY_IPAD 30.0

#define BX_HOME_BUTTONS_X 10.0
#define BX_HOME_BUTTONS_Y 10.0
#define BX_HOME_BUTTONS_X_IPAD 30.0
#define BX_HOME_BUTTONS_Y_IPAD 30.0

#define BX_HOME_BUTTONS_IN_ROW 3
#define BX_HOME_BUTTONS_IN_ROW_IPAD 5

@implementation HomeController

@synthesize stringStatus, stringThumbUrl, stringUserTitle, stringUserInfo, stringUserLocation, isSearchWithPhotos;

- (id)init {
	if ((self = [super initWithNibName:@"HomeView" bundle:nil withUser:[Dolphin6AppDelegate getCurrentUser]])) {
        self.title = NSLocalizedString(@"Home Tab", @"Home tab title");
        self.tabBarItem.image = [UIImage imageNamed:@"tab_home.png"];
        isSearchWithPhotos = YES;
	}
	return self;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	// left nav item
	UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Logout", @"Logout button title") style:UIBarButtonItemStyleBordered target:self action:@selector(actionBack:)];
	self.navigationItem.leftBarButtonItem = btn;
	[btn release];	
	
	// right nav item
	UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reload", @"Reload button title") style:UIBarButtonItemStyleBordered target:self action:@selector(actionReload:)];
	self.navigationItem.rightBarButtonItem = btn2;
	[btn2 release];	
	
	self.navigationItem.title = user.strUsername;	
				
	[Designer applyStylesForScreen:self.view];
	    
	[self requestHomepageInfo];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (isReloadProfileInfoRequired) {
		[self requestHomepageInfo];
		isReloadProfileInfoRequired = false;
	} else {
		[btnMail setBubbleText:[NSString stringWithFormat:@"%d", user.numUnreadLetters]];
		[btnFriends setBubbleText:[NSString stringWithFormat:@"%d", user.numFriendRequests]];
	}
    [self fixScroll];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromOrient
{
    [super didRotateFromInterfaceOrientation:fromOrient];
    
	UIInterfaceOrientation toOrient = self.interfaceOrientation;
    
    CGRect r = CGRectNull;
    if ((fromOrient == UIInterfaceOrientationLandscapeLeft || fromOrient == UIInterfaceOrientationLandscapeRight) && (UIInterfaceOrientationPortrait == toOrient || UIInterfaceOrientationPortraitUpsideDown == toOrient)) {        
        r = viewScroll.frame;
        r.origin.x = 0.0;
        r.size.width = self.view.frame.size.width;
    } else if ((fromOrient == UIInterfaceOrientationPortrait || fromOrient == UIInterfaceOrientationPortraitUpsideDown) && (UIInterfaceOrientationLandscapeLeft == toOrient || UIInterfaceOrientationLandscapeRight == toOrient)) {
        CGFloat fOffsetPortrait = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? BX_HOME_BUTTONS_OFFSET_PORTRAIT_IPAD : BX_HOME_BUTTONS_OFFSET_PORTRAIT_IPHONE;
        r = viewScroll.frame;
        r.origin.x = fOffsetPortrait;
        r.size.width = self.view.frame.size.width - fOffsetPortrait;
    }
        
    if (!CGRectIsNull(r)) {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

        viewScroll.frame = r;
        
        [UIView commitAnimations];
        
        CGSize sz = viewScroll.contentSize;
        sz.width = r.size.width;
        viewScroll.contentSize = sz;
    }
    
}

- (void)deallocUserStrings {    
    if (stringThumbUrl != nil) {
        [stringThumbUrl release];
        stringThumbUrl = nil;
    }
    if (stringStatus != nil) {
        [stringStatus release];
        stringStatus = nil;
    }
    if (stringUserTitle != nil) {
        [stringUserTitle release];
        stringUserTitle = nil;
    }
    if (stringUserInfo != nil) {
        [stringUserInfo release];
        stringUserInfo = nil;
    }
    if (stringUserLocation != nil) {
        [stringUserLocation release];
        stringUserLocation = nil;
    }
}


- (void)dealloc {
	[viewScroll release];
    
    [self deallocUserStrings];
	
    [self removeButtons];
    
	[btnMail release];
	[btnFriends release];
    
	[super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)setReloadRequired {
	isReloadProfileInfoRequired = true;
}

- (void)requestHomepageInfo {
	
    NSArray *myArray;
    NSString *sMethod;
    NSLog(@"user.intProtocolVer = %d", user.intProtocolVer);
    if (user.intProtocolVer > 1) {
        myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0], nil];
        sMethod = @"dolphin.getHomepageInfo2";
    } else {        
        myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, nil];
        sMethod = @"dolphin.getHomepageInfo";
    }    
    [self addProgressIndicator];
    [user.connector execAsyncMethod:sMethod withParams:myArray withSelector:@selector(actionRequestHomepageInfo:) andSelectorObject:self andSelectorData:nil useIndicator:nil];

}


- (HomeButtonView*)initButtonWithTitle:(NSString*)aTitle icon:(NSString*)anIcon index:(NSInteger)anIndex action:(NSString*)anAction bubble:(NSString*)aBubble {
    HomeButtonView* btn = [[HomeButtonView alloc] initWithOrigin:CGPointZero text:aTitle imageResource:anIcon index:anIndex indexAction:[anAction intValue] delegate:self];
    if (nil != aBubble && ![aBubble isEqualToString:@""])
        [btn setBubbleText:aBubble];
	return btn;
}

- (HomeButtonView*)initButton3rdPartyWithTitle:(NSString*)aTitle icon:(NSString*)anIconUrl index:(NSInteger)anIndex action:(NSString*)anAction actionData:(NSString*)anActionData bubble:(NSString*)aBubble {    
    HomeButtonView* btn = [[HomeButton3rdPartyView alloc] initWithOrigin:CGPointZero text:aTitle imageResource:anIconUrl index:anIndex indexAction:[anAction intValue] data:anActionData delegate:self];
    if (nil != aBubble && ![aBubble isEqualToString:@""])
        [btn setBubbleText:aBubble];
    return btn;
}

- (void)removeButtons {
    
    if (nil != aButtons) {
        
        int iCount = [aButtons count];
        for (int i = 1; i<=iCount ; ++i) {
            HomeButtonView *oBtn = [aButtons objectAtIndex:i-1];
            [oBtn removeFromSuperview];
            [oBtn release];
        }
        
        [aButtons release];
        aButtons = nil;
    }
}

- (void)reloadButtons:(NSArray*)aMenu {
    
    [self removeButtons];
        
    aButtons = [[NSMutableArray alloc] init];
    
    int iCount = [aMenu count];
    for (int i = 0; i<iCount ; ++i) {
        
        NSMutableDictionary *dict = [aMenu objectAtIndex:i];
        
        HomeButtonView *btn;
        NSString *sTitle = [dict valueForKey:@"title"];
        NSString *sIcon = [dict valueForKey:@"icon"];
        NSString *sAction = [dict valueForKey:@"action"];
        NSString *sActionData = [dict valueForKey:@"action_data"];
        NSString *sBubble = [dict valueForKey:@"bubble"];
        
        if (nil == sIcon || [sIcon isEqualToString:@""])
            sIcon = @"home_default.png";
                
        if (nil == sActionData || [sActionData isEqualToString:@""])
            btn = [self initButtonWithTitle:sTitle icon:sIcon index:i action:sAction bubble:sBubble];
        else
            btn = [self initButton3rdPartyWithTitle:sTitle icon:sIcon index:i action:sAction actionData:sActionData bubble:sBubble];
            
        if (3 == [sAction intValue]) {
            if (btnMail != nil) {
                [btnMail release];
                btnMail = nil;
            }
            btnMail = [btn retain];
            if ([sBubble intValue] != user.numUnreadLetters) 
                [user setUnreadLettersNum:[sBubble intValue]];                
        }

        if (4 == [sAction intValue]) {
            if (btnFriends != nil) {
                [btnFriends release];
                btnFriends = nil;
            }
            btnFriends = [btn retain];
            if ([sBubble intValue] != user.numFriendRequests) 
                [user setFriendRequestsNum:[sBubble intValue]];                
        }

        [aButtons addObject:btn];        
    }
    
    int iButtonsInRow = BX_HOME_BUTTONS_IN_ROW;
    float fDeltaX = BX_HOME_BUTTONS_DX;
    float fDeltaY = BX_HOME_BUTTONS_DY;
    float fOffsetX = BX_HOME_BUTTONS_X;
    float fOffsetY = BX_HOME_BUTTONS_Y;
    int fScrollOffset = 113;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        iButtonsInRow = BX_HOME_BUTTONS_IN_ROW_IPAD;
        fDeltaX = BX_HOME_BUTTONS_DX_IPAD;
        fDeltaY = BX_HOME_BUTTONS_DY_IPAD;
        fOffsetX = BX_HOME_BUTTONS_X_IPAD;
        fOffsetY = BX_HOME_BUTTONS_Y_IPAD;
        fScrollOffset = 153;
    }
    
    CGPoint p = CGPointMake(fOffsetX, fOffsetY);
    iCount = [aButtons count];
    for (int i = 1; i<=iCount ; ++i) {
        HomeButtonView *oBtn = [aButtons objectAtIndex:i-1];
        [oBtn changeOrigin:p];
        p.x += BX_HOME_BUTTON_WIDTH + fDeltaX;
        if (0 == (i % iButtonsInRow)) {
            p.x = fOffsetX;
            p.y += BX_HOME_BUTTON_HEIGHT + fDeltaY;
        }
        [viewScroll addSubview:oBtn];
    }    
        
    viewScroll.contentSize = CGSizeMake(viewScroll.contentSize.width, fScrollOffset + ((iCount-1) / iButtonsInRow) * (BX_HOME_BUTTON_HEIGHT + fDeltaY));
    [self fixScroll];
}

- (void)fixScroll {
    CGFloat w = self.view.frame.size.width;
    CGFloat d = 0;
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        CGFloat fOffsetPortrait = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? BX_HOME_BUTTONS_OFFSET_PORTRAIT_IPAD : BX_HOME_BUTTONS_OFFSET_PORTRAIT_IPHONE;
        d = fOffsetPortrait;
        w -= fOffsetPortrait;
    }
    
    viewScroll.frame = CGRectMake(d, 0.0, self.view.frame.size.width - d, self.view.frame.size.height);
    viewScroll.contentSize = CGSizeMake(w, viewScroll.contentSize.height);
}

- (void)reloadButtonsUnreadLetters:(NSString*)unreadLetters friendRequests:(NSString*)friendRequests {
    NSArray *aMenu = [[NSArray alloc] initWithObjects:
                       [NSDictionary 
                        dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Status", @"Status title"), @"home_status.png", @"1", nil] 
                        forKeys:[NSArray arrayWithObjects:@"title", @"icon", @"action", nil]],
                       [NSDictionary 
                        dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Location", @"Location title"), @"home_location.png", @"2", nil] 
                        forKeys:[NSArray arrayWithObjects:@"title", @"icon", @"action", nil]],
                      [NSDictionary 
                       dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Mail row with 0 unread", @"Mail title with no unread letters"), @"home_messages.png", @"3", unreadLetters, nil] 
                       forKeys:[NSArray arrayWithObjects:@"title", @"icon", @"action", @"bubble", nil]],
                      [NSDictionary 
                       dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Friends row with 0 requests", @"Friends title with no friend requests"), @"home_friends.png", @"4", friendRequests, nil] 
                       forKeys:[NSArray arrayWithObjects:@"title", @"icon", @"action", @"bubble", nil]],
                      [NSDictionary 
                       dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Info", @"Info title"), @"home_info.png", @"5", nil] 
                       forKeys:[NSArray arrayWithObjects:@"title", @"icon", @"action", nil]],
                      [NSDictionary 
                       dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Search row", @"Search row title"), @"home_search.png", @"6", nil] 
                       forKeys:[NSArray arrayWithObjects:@"title", @"icon", @"action", nil]],
                      [NSDictionary 
                       dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Images tab", @"Images row title"), @"home_images.png", @"7", nil] 
                       forKeys:[NSArray arrayWithObjects:@"title", @"icon", @"action", nil]],
                      [NSDictionary 
                       dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Music profile block", @"Profile music block caption"), @"home_sounds.png", @"9", nil] 
                       forKeys:[NSArray arrayWithObjects:@"title", @"icon", @"action", nil]],
                      [NSDictionary 
                       dictionaryWithObjects: [NSArray arrayWithObjects:NSLocalizedString(@"Video profile block", @"Profile video block caption"), @"home_videos.png", @"8", nil] 
                       forKeys:[NSArray arrayWithObjects:@"title", @"icon", @"action", nil]],
                       nil
                       ];
    [self reloadButtons:aMenu];
    [aMenu release];
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * callback function on request info 
 */
- (void)actionRequestHomepageInfo:(id)idData {	
	
	[self removeProgressIndicator];
	
	id resp = [[idData valueForKey:BX_KEY_RESP] retain];
	
	// if error occured 
	if ([resp isKindOfClass:[NSError class]] || [resp valueForKey:@"error"])
	{		
		[BxConnector showErrorAlertWithDelegate:self];
		return;
	}
	
	NSLog(@"requested info: %@", resp);
	
    [self deallocUserStrings];
    
    isSearchWithPhotos = YES;
    if (nil != [resp valueForKey:@"search_with_photos"])
        isSearchWithPhotos = [[resp valueForKey:@"search_with_photos"] isEqualToString:@"1"] ? YES : NO;
    
	stringStatus = [[resp valueForKey:@"status"] copy];
		
    if (nil != [resp valueForKey:@"thumb"])
        stringThumbUrl = [[NSString alloc] initWithString:[resp valueForKey:@"thumb"]];

    stringUserTitle = [[Dolphin6AppDelegate formatUserTitle:resp default:user.strUsername] copy]; 
    stringUserInfo = [[Dolphin6AppDelegate formatUserInfo:resp] copy];    
    stringUserLocation = [[Dolphin6AppDelegate formatUserLocation:resp] copy];
    
    self.navigationItem.title = stringUserTitle;	
    
    if (user.intProtocolVer > 1) 
        [self reloadButtons:(NSArray*)[resp valueForKey:@"menu"]];
    else
        [self reloadButtonsUnreadLetters:(NSString*)[resp valueForKey:@"unreadLetters"] friendRequests:(NSString*)[resp valueForKey:@"friendRequests"]];
    	
	[resp release];
}

/**
 * open status message update view
 */
- (IBAction)actionOpenStatusMessage:(id)sender {
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	UIViewController *ctrl = [[StatusMessageController alloc] initWithStatusMessage:stringStatus];
	[app.homeNavigationController pushViewController:ctrl animated:YES];
	[ctrl release];	
}

/**
 * open location update view
 */
- (IBAction)actionOpenLocationUpdate:(id)sender {
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	UIViewController *ctrl = [[LocationController alloc] init];
	[app.homeNavigationController pushViewController:ctrl animated:YES];
	[ctrl release];		
}

/**
 * goto home
 */
- (IBAction)actionOpenHome:(id)sender {
	
}

/**
 * open mail
 */
- (IBAction)actionOpenMail:(id)sender {	
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	app.tabController.selectedViewController = app.mailNavigationController;
}

/**
 * open friends
 */
- (IBAction)actionOpenFriends:(id)sender {
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	app.tabController.selectedViewController = app.friendsNavigationController;
}

/**
 * open info
 */
- (IBAction)actionOpenInfo:(id)sender {
    Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	app.tabController.selectedViewController = app.profileNavigationController;
}

/**
 * open search
 */
- (IBAction)actionOpenSearch:(id)sender {
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	app.tabController.selectedViewController = app.searchNavigationController;
}

/**
 * open profile
 */
- (IBAction)actionOpenProfile:(id)sender {    
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	app.tabController.selectedViewController = app.profileNavigationController;
}


/**
 * open images
 */
- (IBAction)actionOpenImages:(id)sender {
    Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	UIViewController *ctrl = [[ImagesAlbumsController alloc] initWithProfile:user.strUsername title:stringUserTitle nav:app.homeNavigationController];
	[app.homeNavigationController pushViewController:ctrl animated:YES];
	[ctrl release];	
}

/**
 * open video
 */
- (IBAction)actionOpenVideo:(id)sender {
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	UIViewController *ctrl = [[VideoAlbumsController alloc] initWithProfile:user.strUsername title:stringUserTitle nav:app.homeNavigationController];
	[app.homeNavigationController pushViewController:ctrl animated:YES];
	[ctrl release];	
}

/**
 * open audio
 */
- (IBAction)actionOpenAudio:(id)sender {
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	UIViewController *ctrl = [[AudioAlbumsController alloc] initWithProfile:user.strUsername title:stringUserTitle nav:app.homeNavigationController];
	[app.homeNavigationController pushViewController:ctrl animated:YES];
	[ctrl release];	
}

/**
 * logout button pressed
 */
- (IBAction)actionBack:(id)sender {
	Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
	[app logout];
}

/**
 * reload button pressed
 */
- (IBAction)actionReload:(id)sender {
	self.navigationItem.rightBarButtonItem.customView.hidden = YES;
	[self requestHomepageInfo];
}

/**********************************************************************************************************************
 DELEGATES
 **********************************************************************************************************************/

#pragma mark - Delegates

- (void)homeButtonPressed:(NSInteger)anIndex indexAction:(NSInteger)anIndexAction {
	NSLog(@"homeButtonPressed: %d action:%d", anIndex, anIndexAction);
	switch (anIndexAction) {
		case 1:
			[self actionOpenStatusMessage:nil];
			break;		
		case 2:
			[self actionOpenLocationUpdate:nil];
			break;					
		case 3:
			[self actionOpenMail:nil];
			break;
		case 4:
			[self actionOpenFriends:nil];
			break;
		case 5:
			[self actionOpenInfo:nil];
			break;			
		case 6:
			[self actionOpenSearch:nil];
			break;
		case 7:
			[self actionOpenImages:nil];
			break;
		case 8:
			[self actionOpenVideo:nil];
			break;
		case 9:
			[self actionOpenAudio:nil];
			break;					
        case 100:
		case 101:
            {
                Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
                HomeButton3rdPartyView *btn = (HomeButton3rdPartyView *)[aButtons objectAtIndex:anIndex];
                NSLog(@"homeButtonPressed URL: %@", [btn getData]);
                [self openPageUrl:[btn getData] title:[btn getTitle] nav:app.homeNavigationController openInNewWindow:(101 == anIndexAction ? YES : NO)];
            }
			break;		
            
	}	
}

@end
