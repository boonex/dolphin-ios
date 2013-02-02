//
//  MediaPlayerController.h
//  Dolphin6
//
//  Created by Alex Trofimov on 14/03/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MediaPlayerController : UIViewController <UIWebViewDelegate> {
    NSString *profile;
    NSString *albumId;
    NSString *mediaId;
    NSString *method;
    NSString *url;
    MPMoviePlayerController *player;
    UINavigationController *navContrioller;
    IBOutlet UIActivityIndicatorView *viewIndicator;
    IBOutlet UIWebView *webView;
}

- (id)initWithUrl:(NSString *)strUrl nav:(UINavigationController*)aNav;
- (id)initWithVideoAlbum:(NSString*)anAlbumId profile:(NSString*)aProfile selectedMediaId:(NSString*)aMediaId nav:(UINavigationController*)aNav;
- (id)initWithAudioAlbum:(NSString*)anAlbumId profile:(NSString*)aProfile selectedMediaId:(NSString*)aMediaId nav:(UINavigationController*)aNav;

- (IBAction)actionCancel:(id)sender;
- (void)beginShow;
- (void)requestMedia;

@end
