//
//  AsyncImageView.h
//  Dolphin6
//
//  Created by Alex Trofimov on 3/03/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AsyncImageViewDelegate
- (void)loadingFinished:(UIImageView*)aImageView;
@end

@interface AsyncImageView : UIView {
    NSURLConnection* connection;
    NSMutableData* data;
	UIActivityIndicatorView *viewActivity;
	NSObject<AsyncImageViewDelegate> *delegate;
	BOOL ajustFrameToImageSize;
	BOOL loading;
	NSString *strProfile;
	UINavigationController *navController;
}

@property (nonatomic, retain) NSObject<AsyncImageViewDelegate> *delegate;
@property (nonatomic, assign) BOOL ajustFrameToImageSize;
@property (nonatomic, assign) BOOL loading;

- (BOOL)loadImageFromURL:(NSURL*)url;
- (UIImage*) getImage;
- (void)removeOldImageView;
- (void)setClickable:(NSString*)aProfile navigationController:(UINavigationController*) navController;

@end

