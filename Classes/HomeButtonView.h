//
//  HomeButtonView.h
//  Dolphin6
//
//  Created by Alex Trofimov on 9/03/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackgroundBubbleView.h"

#define BX_HOME_BUTTON_WIDTH 93.0
#define BX_HOME_BUTTON_HEIGHT 93.0

@protocol HomeButtonViewDelegate
- (void)homeButtonPressed:(NSInteger)anIndex indexAction:(NSInteger)anIndexAction;
@end

@interface HomeButtonView : UIButton {
	BackgroundBubbleView *bubble;
	UIView *viewImage;
	UILabel *label;
	NSInteger index;
    NSInteger indexAction;
    NSString *title;
	NSObject<HomeButtonViewDelegate> *delegate;
}

- (id)initWithOrigin:(CGPoint)anOrigin text:(NSString*)aText imageResource:(NSString*)anImageRes index:(NSInteger)anIndex indexAction:(NSInteger)anIndexAction delegate:(NSObject<HomeButtonViewDelegate> *)aDelegate;
- (void)setBubbleText:(NSString*)s;
- (void)changeOrigin:(CGPoint)anOrigin;
- (UIView*)createImageView:(NSString*)sImageName;
- (NSString*)getTitle;

@end
