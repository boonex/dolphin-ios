//
//  Dolphin6AppDelegate.h
//  Dolphin6
//
//  Created by Alexander Trofimov on 8/19/08.
//  Copyright BoonEx 2008. All rights reserved.


#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "config.h"
#import "User.h"

@class BxUser, HomeController, MailHomeController, FriendsHomeController, SearchHomeController, ProfileInfoController;

@interface Dolphin6AppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;	
	UIViewController *splashContoller;
	
	UINavigationController *navigationController;
	
	UINavigationController *homeNavigationController;
	UINavigationController *mailNavigationController;
	UINavigationController *friendsNavigationController;
	UINavigationController *searchNavigationController;
	UINavigationController *profileNavigationController;
	
	IBOutlet UITabBarController *tabController;
	HomeController *home;
	MailHomeController *homeMail;
	FriendsHomeController *homeFriends;
	SearchHomeController *homeSearch;
	ProfileInfoController *homeProfile;
	NSInteger isLoggedIn;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) UINavigationController *homeNavigationController;
@property (nonatomic, retain) UINavigationController *mailNavigationController;
@property (nonatomic, retain) UINavigationController *friendsNavigationController;
@property (nonatomic, retain) UINavigationController *searchNavigationController;
@property (nonatomic, retain) UINavigationController *profileNavigationController;
@property (nonatomic, retain) UITabBarController *tabController;

+ (Dolphin6AppDelegate*) getApp;
+ (BxUser*) getCurrentUser;
+ (NSString*) formatUserTitle: (NSDictionary*)dict;
+ (NSString*) formatUserTitle: (NSDictionary*)dict default:(NSString*)sDefaultTitle;
+ (NSString*) formatUserTitle: (NSDictionary*)dict field:(NSString*)sField default:(NSString*)sDefaultTitle;
+ (NSString*) formatUserInfo: (NSDictionary*)dict;
+ (NSString*) formatUserLocation: (NSDictionary*)dict;

- (void) login:(BxUser*)anUser;
- (void) logout;

@end

