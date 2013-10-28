//
//  BackgroundBubbleView.h
//  Dolphin6
//
//  Created by Alex Trofimov on 10/03/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BX_BUBBLE_HEIGHT 18.0
#define BX_BUBBLE_WIDTH_MAX 50.0
#define BX_BUBBLE_SPACE 5.5

@interface BackgroundBubbleView : UIView {
	UILabel *label;
}

- (id)initWithOrigin:(CGPoint)anOrigin text:(NSString*)aText;
- (void)setText:(NSString*)aText;

@end
