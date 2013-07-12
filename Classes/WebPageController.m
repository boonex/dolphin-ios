//
//  WebPageController.m
//  Dolphin6
//
//  Created by Alex Trofimov on 5/07/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import "WebPageController.h"
#import "ProfileController.h"
#import "MailComposeController.h"
#import "AudioAlbumsController.h"
#import "VideoAlbumsController.h"
#import "ImagesAlbumsController.h"
#import "ImagesController.h"
#import "ImageAddController.h"
#import "MediaPlayerController.h"
#import "LocationViewController.h"
#import "ProfileInfoController.h"
#import "FriendsProfilesController.h"
#import "Designer.h"

@implementation WebPageController

- (id)initWithUrl:(NSString *)anUrl title:(NSString*)aTitle user:(BxUser*)anUser nav:(UINavigationController *)aNav
{
    if ((self = [super initWithNibName:@"WebPageView" bundle:nil withUser:anUser])) {
        strURL = [anUrl copy];
        strTitle = [aTitle copy];
        navController = [aNav retain];
    }
    return self;
}

- (void)dealloc
{
    [navController release];
    [webView release];
    [strURL release];
    [strTitle release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
     
	// left nav item
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back button title") style:UIBarButtonItemStyleBordered target:self action:@selector(actionBack:)];
	self.navigationItem.leftBarButtonItem = backButton;
	[backButton release];

    self.navigationItem.title = strTitle;
    
    [Designer applyStylesForScreen:self.view];
    [Designer applyStylesForScreen:webView];
    
    NSURL *nsUrl = [NSURL URLWithString:strURL];
    NSMutableURLRequest *nsUrlRequest = [NSMutableURLRequest requestWithURL:nsUrl];
    
    BxUser* anUser = [Dolphin6AppDelegate getCurrentUser];
    [anUser setLoggenInCookiesForRequest:nsUrlRequest];
    
    [webView loadRequest:nsUrlRequest];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/**********************************************************************************************************************
 ACTIONS
 **********************************************************************************************************************/

#pragma mark - Actions

- (IBAction)actionBack:(id)sender {
    
    NSLog(@"CAN GO BACK: %@", webView.canGoBack ? @"YES" : @"NO");
    
    if (self.isProgress) 
        [self removeProgressIndicator];
    
    if (webView.canGoBack) {
        [webView goBack];
    } else {
        [navController popViewControllerAnimated:YES];
    }
}


/**********************************************************************************************************************
 DELEGATES
 **********************************************************************************************************************/

#pragma mark - Delegates

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (self.isProgress) 
        [self removeProgressIndicator];

    NSURL *url = [request URL];     
    NSString *scheme = [url scheme];
    
    if ([scheme isEqualToString:@"bxprofile"]) {
        
        NSString *sProfile = [[url resourceSpecifier] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        ProfileController *ctrl = [[ProfileController alloc] initWithProfile:sProfile nav:navController];
        [navController pushViewController:ctrl animated:YES];
        [ctrl release];
        return NO;

    } else if ([scheme isEqualToString:@"bxcontact"]) {
        
        NSString *sProfile = [url user];
        NSString *sProfileTitle = [url host];
        if (!sProfile)
            sProfile = [[url resourceSpecifier] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        MailComposeController *ctrl = [[MailComposeController alloc] initWithRecipient:sProfile recipientTitle:(sProfileTitle ? sProfileTitle : sProfile) subject:nil nav:navController];
        [navController pushViewController:ctrl animated:YES];
        [ctrl release];
        return NO;

    } else if ([scheme isEqualToString:@"bxgoto"]) {
        
        NSString *sGoto = [url resourceSpecifier];
        if ([sGoto isEqualToString:@"home"]) {
            Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
            app.tabController.selectedViewController = app.homeNavigationController;
            if (app.homeNavigationController == navController)
                [app.homeNavigationController popToRootViewControllerAnimated:YES];
        } else if ([sGoto isEqualToString:@"messages"]) {
            Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
            app.tabController.selectedViewController = app.mailNavigationController;
        } else if ([sGoto isEqualToString:@"friends"]) {
            Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
            app.tabController.selectedViewController = app.friendsNavigationController;
        } else if ([sGoto isEqualToString:@"search"]) {
            Dolphin6AppDelegate *app = [Dolphin6AppDelegate getApp];
            app.tabController.selectedViewController = app.searchNavigationController;
        }
        return NO;
        
    } else if ([scheme isEqualToString:@"bxphoto"]) { // bxphoto://USERNAME@ABUM_ID/IMAGE_ID
        
        NSString *sProfile = [url user];
        NSString *sAlbumId = [url host];
        NSString *sImageId = [[url path] stringByReplacingOccurrencesOfString:@"/" withString:@""];
        if (nil == sProfile || nil == sAlbumId || nil == sImageId)
            return YES;
        
        ImagesController *ctrl = [[ImagesController alloc] initWithAlbum:sAlbumId profile:sProfile nav:navController selectedImageId:sImageId];
        [ctrl setWantsFullScreenLayout:YES];
        [navController presentModalViewController:ctrl animated:YES];
        [ctrl release];        
        return NO;
        
    } else if ([scheme isEqualToString:@"bxvideo"]) { // bxphoto://USERNAME@ABUM_ID/VIDEO_ID
        
        NSString *sProfile = [url user];
        NSString *sAlbumId = [url host];
        NSString *sMediaId = [[url path] stringByReplacingOccurrencesOfString:@"/" withString:@""];
        if (nil == sProfile || nil == sAlbumId || nil == sMediaId)
            return YES;
        
        MediaPlayerController *ctrl = [[MediaPlayerController alloc] initWithVideoAlbum:sAlbumId profile:sProfile selectedMediaId:sMediaId nav:navController];
        [navController pushViewController:ctrl animated:YES];
        [ctrl release];
        return NO;

    } else if ([scheme isEqualToString:@"bxaudio"]) { // bxaudio://USERNAME@ABUM_ID/SOUND_ID
        
        NSString *sProfile = [url user];
        NSString *sAlbumId = [url host];
        NSString *sMediaId = [[url path] stringByReplacingOccurrencesOfString:@"/" withString:@""];
        if (nil == sProfile || nil == sAlbumId || nil == sMediaId)
            return YES;
        
        MediaPlayerController *ctrl = [[MediaPlayerController alloc] initWithAudioAlbum:sAlbumId profile:sProfile selectedMediaId:sMediaId nav:navController];
        [navController pushViewController:ctrl animated:YES];
        [ctrl release];
        return NO;
        
    } else if ([scheme isEqualToString:@"bxphotoupload"]) { // bxphotoupload:ALBUM_NAME
        
        NSString *sAlbumName = [[url resourceSpecifier] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (nil == sAlbumName)
            return YES;
        
        ImageAddController *ctrl = [[ImageAddController alloc] initWithAlbum:sAlbumName mediaListController:nil nav:navController];
        [navController pushViewController:ctrl animated:YES];
        [ctrl release];
        return NO;
        
    } else if ([scheme isEqualToString:@"bxlocation"]) { //  bxlocation:USERNAME
        
        NSString *sProfile = [[url resourceSpecifier] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (nil == sProfile)
            return YES;
        
        LocationViewController *ctrl = [[LocationViewController alloc] initWithProfile:sProfile nav:navController];
        [navController pushViewController:ctrl animated:YES];
        [ctrl release];
        return NO;
        
    } else if ([scheme isEqualToString:@"bxprofilefriends"]) { //  bxprofilefriends:USERNAME
        
        NSString *sProfile = [[url resourceSpecifier] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (nil == sProfile)
            return YES;
        
        FriendsProfilesController *ctrl = [[FriendsProfilesController alloc] initWithProfile:sProfile nav:navController];
        [navController pushViewController:ctrl animated:YES];
        [ctrl release];
        return NO;

    } else if ([scheme isEqualToString:@"bxphotoalbums"]) { // bxphotoalbums:USERNAME
        
        NSString *sProfile = [[url resourceSpecifier] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (nil == sProfile)
            return YES;
        
        ImagesAlbumsController *ctrl = [[ImagesAlbumsController alloc] initWithProfile:sProfile nav:navController];
        [navController pushViewController:ctrl animated:YES];
        [ctrl release];
        return NO;
        
    } else if ([scheme isEqualToString:@"bxvideoalbums"]) { // bxvideoalbums:USERNAME
        
        NSString *sProfile = [[url resourceSpecifier] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (nil == sProfile)
            return YES;
        
        VideoAlbumsController *ctrl = [[VideoAlbumsController alloc] initWithProfile:sProfile nav:navController];
        [navController pushViewController:ctrl animated:YES];
        [ctrl release];
        return NO;

    } else if ([scheme isEqualToString:@"bxaudioalbums"]) { // bxaudioalbums:USERNAME
        
        NSString *sProfile = [[url resourceSpecifier] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (nil == sProfile)
            return YES;
        
        AudioAlbumsController *ctrl = [[AudioAlbumsController alloc] initWithProfile:sProfile nav:navController];
        [navController pushViewController:ctrl animated:YES];
        [ctrl release];
        return NO;
        
    } else if ([scheme isEqualToString:@"bxpagetitle"]) { // '<iframe style="width:0px;height:0px;border:0px;" src="bxpagetitle:' . rawurlencode('Custom Title') . '" ></iframe>'
        
        NSString *sTitle = [[url resourceSpecifier] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (nil == sTitle)
            return YES;
        self.navigationItem.title = sTitle;
        return NO;
        
    } 

    
    // open urls with #blank at the end in external browser window
    if ([url.fragment isEqualToString:@"blank"]) {
        if (([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"https"] || [[url scheme] isEqualToString:@"mailto"]) 
            && (navigationType == UIWebViewNavigationTypeLinkClicked)) { 
            NSString *sUrl = [url absoluteString];
            NSRange range = NSMakeRange(sUrl.length-@"#blank".length, @"#blank".length);
            NSString *sUrlWithoutBlank = [sUrl stringByReplacingCharactersInRange:range withString:@""];
            return ![[UIApplication sharedApplication] openURL:[NSURL URLWithString:sUrlWithoutBlank]]; 
        } 
    }
        
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (!self.isProgress) 
        [self addProgressIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.isProgress) 
        [self removeProgressIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"web view error: %@", [error localizedDescription]);
    [BxConnector showErrorAlertWithDelegate:self responce:error];
}

@end
