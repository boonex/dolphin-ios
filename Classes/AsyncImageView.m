//
//  AsyncImageView.m
//  Dolphin6
//
//  Created by Alex Trofimov on 3/03/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import "AsyncImageView.h"
#import "ProfileController.h"
#import "Designer.h"

#define ASYNC_IMAGE_VIEW_CONNECTION_TIMEOUT 30.0
#define ASYNC_IMAGE_VIEW_TAG 95
#define ASYNC_LABEL_VIEW_TAG 96

@implementation AsyncImageView

@synthesize delegate, ajustFrameToImageSize, loading;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
					
		navController = nil;
		strProfile = nil;
		ajustFrameToImageSize = NO;		
		loading = NO;
		
		viewActivity.center = self.center;
		CGRect r = CGRectMake(frame.size.width/2.0 - 10, frame.size.height/2.0 - 10, 20.0, 20.0);
		viewActivity = [[UIActivityIndicatorView alloc] initWithFrame:r];
		viewActivity.hidesWhenStopped = YES;
		viewActivity.autoresizingMask = UIViewAutoresizingNone;
        viewActivity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		[self addSubview:viewActivity];
		
		self.clipsToBounds = YES;
		self.backgroundColor = [UIColor clearColor];
	}
	return self; 
}

- (void)dealloc {
    [connection cancel];
    [connection release];
    [data release];
	[delegate release];
	[viewActivity release];
	[strProfile release];
	[navController release];
    [super dealloc];
}

/**********************************************************************************************************************
 CUSTOM FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Custom Functions

- (void)showErrorLabel {
	UILabel* l = [[UILabel alloc] initWithFrame:self.frame];
	l.text = NSLocalizedString(@"Connection Error", @"Connection Error");
	l.tag = ASYNC_LABEL_VIEW_TAG;
	[Designer applyStylesForErrorMessageInsideThumbnail:l];
	[self addSubview:l];
	[l release];	
}

- (BOOL)loadImageFromURL:(NSURL*)url {
    
    if (data!=nil) { 
		[data release]; 
	}
	
	[self removeOldImageView];
	
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:ASYNC_IMAGE_VIEW_CONNECTION_TIMEOUT];

    BxUser* user = [Dolphin6AppDelegate getCurrentUser];
    [user setLoggenInCookiesForRequest:request];
    
	@synchronized(self) {
		
		if (connection != nil) { 
			[connection cancel];
			[connection release]; 
		}
		
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	}

	if (nil == connection) {
		[self showErrorLabel];
		return NO;
	} else {		
		[viewActivity startAnimating];
		loading = YES;
		return YES;
	}
}

- (UIImage*) getImage {
    UIImageView* iv = (UIImageView*)[self viewWithTag:ASYNC_IMAGE_VIEW_TAG];
    return [iv image];
}

- (void)removeOldImageView {
	
	UIView *viewOld = [self viewWithTag:ASYNC_IMAGE_VIEW_TAG];
    if (nil != viewOld) {
        [viewOld removeFromSuperview];
    }
	
	UIView *viewOldLabel = [self viewWithTag:ASYNC_LABEL_VIEW_TAG];
    if (nil != viewOldLabel) {
        [viewOldLabel removeFromSuperview];
    }
}

- (void)setClickable:(NSString*)aProfile navigationController:(UINavigationController*) aController {
	
	if (strProfile != nil)
		[strProfile release];
	strProfile = [aProfile copy];
	
	if (navController == aController)
		return;
	if (navController != nil)
		[navController release];
	navController = [aController retain];
}

- (void)clickEvent {
	if (nil == strProfile)
		return;
	
	ProfileController * ctrl = [[ProfileController alloc] initWithProfile:strProfile nav:navController];
	[navController pushViewController:ctrl animated:YES];
	[ctrl release];
}

/**********************************************************************************************************************
 DELEGATES
 **********************************************************************************************************************/

#pragma mark - NSURLConnection delegates

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	
    [connection release];
    connection=nil;
	
	[viewActivity stopAnimating];	
	
	[self removeOldImageView];
	
    UIImageView* imageView = [[[UIImageView alloc] initWithImage:[UIImage imageWithData:data]] autorelease];
	imageView.backgroundColor = [UIColor clearColor];
	imageView.tag = ASYNC_IMAGE_VIEW_TAG;
	imageView.contentMode = ajustFrameToImageSize ? UIViewContentModeScaleToFill : UIViewContentModeScaleAspectFit; // UIViewContentModeScaleAspectFit
    imageView.autoresizingMask = UIViewAutoresizingNone;// ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
	
	self.contentMode = UIViewContentModeScaleToFill;
    self.autoresizingMask = UIViewAutoresizingNone; // ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight );
	
	if (ajustFrameToImageSize) {
		CGRect r = self.frame;
		r.origin = CGPointMake(0, 0);
		r.size = imageView.image.size;
		self.center = r.origin;
		self.frame = r;
		
		r = imageView.frame;
		r.origin = CGPointMake(0, 0);
		r.size = imageView.image.size;
		imageView.center = r.origin;
		imageView.frame = r;
	} else {
        imageView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    } 
	
	[self addSubview:imageView];
	
    [imageView setNeedsLayout];	
    [self setNeedsLayout];
	
    [data release];
    data=nil;
	
	loading = NO;
	
	if (delegate)
		[delegate loadingFinished:imageView];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
	
	[connection release];
    connection=nil;
	
	[viewActivity stopAnimating];	
	
	[self removeOldImageView];
	
	[self showErrorLabel];
}

- (void)connection:(NSURLConnection *)theConnection
	didReceiveData:(NSData *)incrementalData {
    if (data == nil) {
		data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
}

/**********************************************************************************************************************
 TOUCHES FUNCTIONS
 **********************************************************************************************************************/

#pragma mark - Touches Functions

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (nil == strProfile)
		return;
	
    UITouch *touch = [touches anyObject];
    if([touch tapCount] == 1) {
        [self clickEvent];
    }
}


@end
