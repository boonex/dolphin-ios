//
//  MediaPlayerController.m
//  Dolphin6
//
//  Created by Alex Trofimov on 14/03/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import "MediaPlayerController.h"
#import "config.h"
#import "Dolphin6AppDelegate.h"
#import "Connector.h"
#import "Designer.h"

@implementation MediaPlayerController

- (id)initWithUrl:(NSString *)strUrl nav:(UINavigationController*)aNav {
    if ((self = [super initWithNibName:@"MediaPlayerView" bundle:nil])) {
        url = [strUrl copy];      
        navContrioller = aNav;
    }
    return self;
}

- (id)initWithVideoAlbum:(NSString*)anAlbumId profile:(NSString*)aProfile selectedMediaId:(NSString*)aMediaId nav:(UINavigationController*)aNav {
    if ((self = [self initWithUrl:nil nav:aNav])) {
        profile = [aProfile copy];
        albumId = [anAlbumId copy];
        mediaId = [aMediaId copy];
        method = @"dolphin.getVideoInAlbum";
    }
    return self;
}

- (id)initWithAudioAlbum:(NSString*)anAlbumId profile:(NSString*)aProfile selectedMediaId:(NSString*)aMediaId nav:(UINavigationController*)aNav {
    if ((self = [self initWithUrl:nil nav:aNav])) {
        profile = [aProfile copy];
        albumId = [anAlbumId copy];
        mediaId = [aMediaId copy];
        method = @"dolphin.getAudioInAlbum";
    }
    return self;
}


- (void)viewDidLoad {
    [Designer applyStylesForScreen:self.view];
    if (nil == url)
        [self requestMedia];
    else
        [self beginShow];
}

// iOS 6
- (NSInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

// iOS 6
- (BOOL)shouldAutorotate {
    return YES;
}

// iOS 5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
    [profile release];
    [albumId release];
    [mediaId release];
	[url release];
	[player release];
    [webView release];
    [super dealloc];
}

/**********************************************************************************************************************
 Custom Function
 **********************************************************************************************************************/

#pragma mark - Custom Function

- (void)beginShow {
    
	if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
        
        webView.hidden = YES;
        
        NSURL *theURL = [NSURL URLWithString:url];
        player = [[MPMoviePlayerController alloc] initWithContentURL:theURL];
            
        [player prepareToPlay];
            
        player.scalingMode = MPMovieScalingModeAspectFit;
            
        // Register that the load state changed (movie is ready)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerLoadStateChanged:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:nil];
        
        // Register to receive a notification when the movie has finished playing. 
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(moviePlayBackDidFinish:) 
                                                     name:MPMoviePlayerPlaybackDidFinishNotification 
                                                   object:nil];        
    } else {
        
        [viewIndicator stopAnimating];
        
        NSLog(@"http://youtube.com/embed/%@", url);
/*                
        NSString* embedHTML = @"\
        <html>\
        <body style=\"margin:0; text-align:center; background-color:transparent; color:#888;\">\
        <iframe width=\"100%%\" height=\"240px\" src=\"http://youtube.com/embed/%@\" frameborder=\"0\" allowfullscreen></iframe>\
        </body></html>";
*/

        NSString* embedHTML = @"\
        <html>\
        <body style=\"margin:0; text-align:center; background-color:transparent; color:#888;\">\
        <object width=\"%d\" height=\"%d\">\
        <param name=\"movie\" value=\"http://www.youtube.com/v/%@\"></param>\
        <embed src=\"http://www.youtube.com/v/%@\" type=\"application/x-shockwave-flash\" width=\"%d\" height=\"%d\"></embed>\
        </object>\
        </body></html>";
        
        int iHeight =  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 480 : 240;
        int iWidth =  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 640 : 320;
        NSString* html = [NSString stringWithFormat:embedHTML, iWidth, iHeight, url, url, iWidth, iHeight];
        
        [webView loadHTMLString:html baseURL:nil];
        
        webView.opaque = NO;
        webView.backgroundColor = [UIColor clearColor];
	}
}

- (void)requestMedia {	
    BxUser *user = [Dolphin6AppDelegate getCurrentUser];
    
    NSArray *myArray = [NSArray arrayWithObjects:user.strUsername, user.strPwdHash, profile, albumId, nil];
    [viewIndicator startAnimating];
    [user.connector execAsyncMethod:method withParams:myArray withSelector:@selector(actionRequestMedia:) andSelectorObject:self andSelectorData:nil useIndicator:nil];
	
}


/**********************************************************************************************************************
 Actions
 **********************************************************************************************************************/

#pragma mark - Actions

/**
 * callback function on contacts list request 
 */
- (void)actionRequestMedia:(id)idData {	
	
    [viewIndicator stopAnimating];
	
	id resp = [idData valueForKey:BX_KEY_RESP];
	
	// if error occured 
	if([resp isKindOfClass:[NSError class]])
	{		
		[BxConnector showErrorAlertWithDelegate:self responce:resp];
		return;
	}

    if([resp isKindOfClass:[NSDictionary class]] && nil != [(NSDictionary *)resp objectForKey:@"faultString"]) {        
        [BxConnector showDictErrorAlertWithDelegate:self responce:resp];
        return;
    }
    
    NSLog(@"media in album (%@): %@", albumId, resp);
    
    NSArray *mediaList = (NSArray *)resp;
    
    int count = [mediaList count];    
	for (int i=0; i<count; ++i) {
        NSMutableDictionary *dict = [mediaList objectAtIndex:i];
        NSString* strId = [dict valueForKey:@"id"];
        if ([strId  isEqualToString:mediaId]) {
            url = [[dict valueForKey:@"file"] copy];
            [self beginShow];
            return;
        }
    }

    // file not found or no files in the album
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") message:NSLocalizedString(@"Error occured", @"Error occured alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button text") otherButtonTitles:nil];
    [al show];
    [al release];		
}


- (IBAction)actionCancel:(id)sender {
    [navContrioller popViewControllerAnimated:YES];
}

/**********************************************************************************************************************
 UIAlertView Deligates
 **********************************************************************************************************************/

#pragma mark - UIAlertView Deligates

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self actionCancel:nil];
}

/**********************************************************************************************************************
 Media Player Deligates
 **********************************************************************************************************************/

#pragma mark - Media Player Deligates

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [viewIndicator stopAnimating];
        
	// Remove observer
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:MPMoviePlayerPlaybackDidFinishNotification
	 object:nil];
	
	[player stop];
	
	if ([player respondsToSelector:@selector(loadState)]) { 		
	
        NSLog(@"respondsToSelector:loadState: YES");
        
		[[NSNotificationCenter defaultCenter]
		 removeObserver:self
		 name:MPMoviePlayerDidExitFullscreenNotification
		 object:nil];
		
		[player setFullscreen:NO];
		[player.view removeFromSuperview];
	}
	
    if (nil != notification.userInfo && [notification.userInfo objectForKey:@"error"]) {
        
        NSError *err = [notification.userInfo objectForKey:@"error"];
        NSLog(@"ERROR localizedDescription: %@", err.localizedDescription);
		UIAlertView *al = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error alert title") 
                                                     message:err.localizedDescription 
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"Close", @"Close button") 
                                           otherButtonTitles:nil];
		[al show];
		[al release];        
        
    } else {    
        [self actionCancel:nil];
    }
}


/*---------------------------------------------------------------------------
 * For 3.2 and 4.x devices
 *--------------------------------------------------------------------------*/
- (void) moviePlayerLoadStateChanged:(NSNotification*)notification 
{
    
	// Unless state is unknown, start playback
	if ([player loadState] != MPMovieLoadStateUnknown)
	{
        [viewIndicator stopAnimating];
        
		// Remove observer
		[[NSNotificationCenter defaultCenter] 
		 removeObserver:self
		 name:MPMoviePlayerLoadStateDidChangeNotification 
		 object:nil];
		
		// Set frame of movie player
		[player.view setFrame:self.view.bounds];
		
		// Add movie player as subview
		[self.view addSubview:player.view];   
        
		[player setFullscreen:YES];
        		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(moviePlayBackDidFinish:) 
													 name:MPMoviePlayerDidExitFullscreenNotification
												   object:nil];
        
		// Play the movie
		[player play];

	}
}

/**********************************************************************************************************************
 Web View Deligates
 **********************************************************************************************************************/

#pragma mark - Web View Deligates

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [viewIndicator startAnimating];    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [viewIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"web view error: %@", [error localizedDescription]);
    [BxConnector showErrorAlertWithDelegate:self responce:error];
}

@end
