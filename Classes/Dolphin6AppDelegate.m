//
//  Dolphin6AppDelegate.m
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/19/08.
//  Copyright BoonEx 2008. All rights reserved.
//

#import "Dolphin6AppDelegate.h"
#import "DolphinUsers.h"
#import "InitialController.h"
#import "LoginController.h"
#import "User.h"
#import "Designer.h"
#import "HomeController.h"
#import "MailHomeController.h"
#import "FriendsHomeController.h"
#import "SearchHomeController.h"
#import "profileInfoController.h"

@implementation Dolphin6AppDelegate

static Dolphin6AppDelegate *glApp = nil;
static BxUser *glUser = nil;

@synthesize window, navigationController, homeNavigationController, mailNavigationController, friendsNavigationController, searchNavigationController, profileNavigationController, tabController;

- (id)init {
	if (!glApp) {
		glApp = [super init];
	}
	return glApp;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [application setStatusBarStyle:UIStatusBarStyleDefault];
    [application setStatusBarHidden:NO withAnimation:NO];
    
    InitialController *aInitialController = [[InitialController alloc] initWithNibName:@"InitialView" bundle:[NSBundle mainBundle]];
    navigationController =	[[UINavigationController alloc] initWithRootViewController:aInitialController];
    [aInitialController release];
    
    DolphinUsers *users = [DolphinUsers sharedDolphinUsers];
    if (1 == [users countOfUsers]) {
        BxUser *user = [users userAtIndex:0];
        if (user.strPwdHash.length > 0 && YES == user.rememberPassword) {
            LoginController *aLoginController = [[LoginController alloc] initWithUserObject:user];
            [navigationController pushViewController:aLoginController animated:NO];
            [aLoginController release];
        }
    }
    
    
    navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    [self.window setRootViewController:navigationController];
    
    [window makeKeyAndVisible];
    
    return YES;
}

- (void) login:(BxUser*)anUser {
	
	if (YES == isLoggedIn || glUser != nil || tabController != nil)
		return;
	
	isLoggedIn = YES;
	glUser = [anUser retain];
	
	[navigationController popToRootViewControllerAnimated:NO];
	[navigationController.view removeFromSuperview];
	
	home = [[HomeController alloc] init];
	homeMail = [[MailHomeController alloc] init];
	homeFriends = [[FriendsHomeController alloc] init];
	homeSearch = [[SearchHomeController alloc] init];
	homeProfile = [[ProfileInfoController alloc] initWithProfile:glUser.strUsername title:nil thumb:nil info:nil location:nil nav:nil];
		
	homeNavigationController = [[UINavigationController alloc] initWithRootViewController:home];
	mailNavigationController = [[UINavigationController alloc] initWithRootViewController:homeMail];
	friendsNavigationController = [[UINavigationController alloc] initWithRootViewController:homeFriends];
	searchNavigationController = [[UINavigationController alloc] initWithRootViewController:homeSearch];
	profileNavigationController = [[UINavigationController alloc] initWithRootViewController:homeProfile];
	
	homeNavigationController.navigationBar.barStyle = UIBarStyleDefault;
	mailNavigationController.navigationBar.barStyle = UIBarStyleDefault;
	friendsNavigationController.navigationBar.barStyle = UIBarStyleDefault;
	searchNavigationController.navigationBar.barStyle = UIBarStyleDefault;
	profileNavigationController.navigationBar.barStyle = UIBarStyleDefault;
	
	tabController = [[UITabBarController alloc] init];
	[window addSubview:tabController.view];
	[tabController setViewControllers:[NSArray arrayWithObjects:homeNavigationController, profileNavigationController, mailNavigationController, friendsNavigationController, searchNavigationController, nil] animated:NO];
    
    window.rootViewController = tabController;
    
    // tab bar customization
    [Designer applyStylesForTabbar:[tabController tabBar] orientation:tabController.interfaceOrientation];
    
}

- (void) logout {
	
	if (NO == isLoggedIn)
		return;	
	
	isLoggedIn = NO;
	
	[tabController.view removeFromSuperview];
	
	[window addSubview:navigationController.view];

	tabController.viewControllers =	[NSArray array];
	[tabController release];
	tabController = nil;

    window.rootViewController = navigationController;
    
	[homeNavigationController popToRootViewControllerAnimated:NO];
	[mailNavigationController popToRootViewControllerAnimated:NO];
	[friendsNavigationController popToRootViewControllerAnimated:NO];
	[searchNavigationController popToRootViewControllerAnimated:NO];	
	[profileNavigationController popToRootViewControllerAnimated:NO];	
	
	[homeNavigationController release];
	[mailNavigationController release];
	[friendsNavigationController release];
	[searchNavigationController release];
	[profileNavigationController release];
	
	homeNavigationController = nil;
	mailNavigationController = nil;
	friendsNavigationController = nil;
	searchNavigationController = nil;
	profileNavigationController = nil;
	
	[home release];
	[homeMail release];
	[homeFriends release];
	[homeSearch release];
	[homeProfile release];
	
	home = nil;
	homeMail = nil;
	homeFriends = nil;
	homeSearch = nil;
	homeProfile = nil;
	
    glUser.rememberPassword = NO;
    glUser.strPwdHash = @"";
	DolphinUsers *users = [DolphinUsers sharedDolphinUsers];
	[users saveUsers];
    
	[glUser release];
	glUser = nil;
    
    [self logoutFB];
}

- (void) logoutFB {
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [loginManager dealloc];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// save data on app quit
	DolphinUsers *users = [DolphinUsers sharedDolphinUsers];
	[users saveUsers];
    
    [self logoutFB];
}

- (void)dealloc {
	[splashContoller release];
	
	[home release];
	[homeMail release];
	[homeFriends release];
	[homeSearch release];
	
	[homeNavigationController popToRootViewControllerAnimated:NO];
	[mailNavigationController popToRootViewControllerAnimated:NO];
	[friendsNavigationController popToRootViewControllerAnimated:NO];
	[searchNavigationController popToRootViewControllerAnimated:NO];
	[navigationController popToRootViewControllerAnimated:NO];
	
	[homeNavigationController release];
	[mailNavigationController release];
	[friendsNavigationController release];
	[searchNavigationController release];
	[navigationController release];
	
	[tabController release];
	
	[window release];
	glApp = nil;
	[super dealloc];
}

+ (Dolphin6AppDelegate*) getApp {
	return glApp;
}

+ (BxUser*) getCurrentUser {
	return glUser;
}

+ (NSString*) formatUserTitle: (NSDictionary*)dict {
    return [self formatUserTitle:dict default:@""];
}

+ (NSString*) formatUserTitle: (NSDictionary*)dict default:(NSString*)sDefaultTitle {
    return [self formatUserTitle:dict field:@"user_title" default:sDefaultTitle];
}

+ (NSString*) formatUserTitle: (NSDictionary*)dict field:(NSString*)sField default:(NSString*)sDefaultTitle {
    
    if ([self getCurrentUser].intProtocolVer > 2) {
        
        return [NSString stringWithString:[dict valueForKey:sField] ? [dict valueForKey:sField] : sDefaultTitle];
        
    } else {
        
        return [NSString stringWithString:[dict valueForKey:@"Nick"] ? [dict valueForKey:@"Nick"] : sDefaultTitle];
    
    }
    
}

+ (NSString*) formatUserInfo: (NSDictionary*)dict {
    
    if ([self getCurrentUser].intProtocolVer > 2) {
        
        NSString *sUserInfo = [dict valueForKey:@"user_info"];
        return [NSString stringWithString:(nil == sUserInfo ? @"" : sUserInfo)];
        
    } else {
    
        NSString* age = [dict valueForKey:@"Age"] ? [dict valueForKey:@"Age"] : [dict valueForKey:@"age"];
        NSString* sex = NSLocalizedString([dict valueForKey:@"Sex"] ? [dict valueForKey:@"Sex"] : [dict valueForKey:@"sex"], @"Gender/Sex");
	
        NSString* info;
        if (age != nil && ![age isEqualToString:@""] && ![age isEqualToString:@"unknown"] && sex != nil)
            info = [NSString stringWithFormat:NSLocalizedString(@"<Age> y/o <Sex>", @"User info text"), age, sex];
        else if (age != nil && ![age isEqualToString:@""] && ![age isEqualToString:@"unknown"])
            info = [NSString stringWithFormat:NSLocalizedString(@"<Age> y/o", @"User info text"), age];
        else if (sex != nil && ![sex isEqualToString:@""])
            info = [NSString stringWithString:sex];
        else 
            info = @"";
        
        return [[[NSString alloc] initWithString:info] autorelease];
    }
}

+ (NSString*) formatUserLocation: (NSDictionary*)dict {
    
    if ([self getCurrentUser].intProtocolVer > 2) {
        
        return [NSString stringWithString:[dict valueForKey:@"user_location"]];

    } else {
        
        NSString* city = [dict valueForKey:@"City"] ? [dict valueForKey:@"City"] : [dict valueForKey:@"city"];
        NSString* country = [dict valueForKey:@"Country"] ? [dict valueForKey:@"Country"] : [dict valueForKey:@"country"];
	
        NSString* location;
        if (country != nil && city != nil && ![country isEqualToString:@""] && ![city isEqualToString:@""])
            location = [NSString stringWithFormat:NSLocalizedString(@"%@, %@", @"city, country format"), city, country];
        else if (country != nil && ![country isEqualToString:@""])
            location = [NSString stringWithString:country];
        else
            location = @"";
    
        return [[[NSString alloc]initWithString:location] autorelease];
    }
}


@end
