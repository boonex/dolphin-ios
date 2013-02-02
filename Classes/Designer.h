//
//  Designer.h
//  Dolphin6
//
//  Created by Alex Trofimov on 24/02/11.
//  Copyright 2011 BoonEx. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BX_DESIGNER_BG_TAG 25
#define BX_DESIGNER_BG_TAG_SEL 26

@interface Designer : NSObject {

}

+ (void)applyStylesForCell:(UITableViewCell*)cell;
+ (void)applyStylesClear:(UIView*)view;
+ (void)applyStylesForScreen:(UIView*)view;
+ (void)applyStylesForTableBackgroundClear:(UITableView*)table;
+ (void)applyStylesForContainer:(UIView*)view;
+ (void)applyStylesForLabel:(UILabel*)label;
+ (void)applyStylesForLabelTitle:(UILabel*)label;
+ (void)applyStylesForLabelDesc:(UILabel*)label;
+ (void)applyStylesForLabelNew:(UILabel*)label;
+ (void)applyStylesForTextEdit:(UITextField*)textEdit;
+ (void)applyStylesForTextArea:(UITextView*)textArea;
+ (void)applyStylesForWebView:(UIWebView*)webView;
+ (void)applyStylesForButton:(UIButton*)btn;
+ (void)applyStylesForErrorMessageInsideThumbnail:(UILabel*)label;

+ (void)applyStylesForLabelHomeButton:(UILabel*)label;
+ (void)applyStylesForHomeButton:(UIView*)view;
+ (void)applyStylesForLabelBubble:(UILabel*)label;
+ (CGSize)sizeForBubbleLabel:(NSString*)s maxWidth:(CGFloat)fMaxWidth maxHeight:(CGFloat)fMaxHeight;

+ (void)applyStylesForLabelStatus:(UILabel*)label;
+ (CGSize)sizeForProfileStatusLabel:(NSString*)s maxWidth:(CGFloat)fMaxWidth maxHeight:(CGFloat)fMaxHeight;

+ (void)applyStylesForLabelProfileInfoCaption:(UILabel*)label;
+ (CGSize)sizeForLabelProfileInfoCaption:(NSString*)s maxWidth:(CGFloat)fMaxWidth maxHeight:(CGFloat)fMaxHeight;
+ (void)applyStylesForLabelProfileInfo:(UILabel*)label;
+ (CGSize)sizeForProfileInfo:(NSString*)s maxWidth:(CGFloat)fMaxWidth maxHeight:(CGFloat)fMaxheight;
+ (void)applyStylesForLabelProfileInfoArea:(UILabel*)label;
+ (CGSize)sizeForProfileInfoArea:(NSString*)s maxWidth:(CGFloat)fMaxWidth maxHeight:(CGFloat)fMaxheight;

+ (void)applyStylesForTabbar:(UITabBar*)tabBar orientation:(UIInterfaceOrientation)interfaceOrientation;

@end
