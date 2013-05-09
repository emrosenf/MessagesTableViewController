//
//  JSBubbleView.m
//
//  Created by Jesse Squires on 2/12/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//  http://www.hexedbits.com
//
//
//  Largely based on work by Sam Soffes
//  https://github.com/soffes
//
//  SSMessagesViewController
//  https://github.com/soffes/ssmessagesviewcontroller
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "JSBubbleView.h"
#import "JSMessageInputView.h"
#import "NSString+JSMessagesView.h"

#define kMarginTop 8.0f
#define kMarginBottom 4.0f
#define kAvatarMargin 20.0f
#define kPaddingTop 4.0f
#define kPaddingTopUS2 7.0f
#define kPaddingTopUS2GreenBlue 8.0f
#define kPaddingBottom 8.0f
#define kBubblePaddingRight 35.0f
#define kPaddingLeftOffset 3.0f
#define kPaddingLeftOffsetUS2 5.0f

@interface JSBubbleView()

@property (assign, nonatomic) CGSize avatarSize;

- (void)setup;

@end



@implementation JSBubbleView

@synthesize style;
@synthesize text;

#pragma mark - Initialization
- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame bubbleStyle:(JSBubbleMessageStyle)bubbleStyle avatarSize:(CGSize)avatarSize
{
    self = [super initWithFrame:frame];
    if(self) {
        self.style = bubbleStyle;
        self.avatarSize = avatarSize;
        [self setup];
    }
    return self;
}

#pragma mark - Setters
- (void)setStyle:(JSBubbleMessageStyle)newStyle
{
    style = newStyle;
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)newText
{
    text = newText;
    [self setNeedsDisplay];
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)frame
{
	UIImage *image = [JSBubbleView bubbleImageForStyle:self.style];
    CGSize bubbleSize = [JSBubbleView bubbleSizeForText:self.text style:self.style];
    CGFloat margin =  self.avatarSize.width > 0 ? kAvatarMargin : 0;
	CGRect bubbleFrame = CGRectMake(([JSBubbleView styleIsOutgoing:self.style] ? self.frame.size.width - bubbleSize.width - self.avatarSize.width - margin: 0.0f + self.avatarSize.width + margin),
                                    kMarginTop,
                                    bubbleSize.width,
                                    bubbleSize.height);
    
	[image drawInRect:bubbleFrame];
	
	CGSize textSize = [JSBubbleView textSizeForText:self.text style:self.style];
	CGFloat textX = (CGFloat)image.leftCapWidth - [JSBubbleView leftOffsetForStyle:self.style] + ([JSBubbleView styleIsOutgoing:self.style] ? bubbleFrame.origin.x : 0.0f + self.avatarSize.width + margin);
    CGRect textFrame = CGRectMake(textX,
                                  [JSBubbleView topPaddingForStyle:self.style] + kMarginTop,
                                  textSize.width,
                                  textSize.height);
    
	[self.text drawInRect:textFrame
                 withFont:[JSBubbleView font]
            lineBreakMode:NSLineBreakByWordWrapping
                alignment:NSTextAlignmentLeft];
}

#pragma mark - Bubble view
+ (BOOL)styleIsOutgoing:(JSBubbleMessageStyle)bubbleStyle
{
    return (bubbleStyle == JSBubbleMessageStyleOutgoingDefault
            || bubbleStyle == JSBubbleMessageStyleOutgoingDefaultGreen
            || bubbleStyle == JSBubbleMessageStyleOutgoingSquare
            || bubbleStyle == JSBubbleMessageStyleOutgoingUS2GreenTailed
            || bubbleStyle == JSBubbleMessageStyleOutgoingUS2Green
            || bubbleStyle == JSBubbleMessageStyleOutgoingUS2Blue
            || bubbleStyle == JSBubbleMessageStyleOutgoingUS2BlueTailed);
}

+ (BOOL)styleIsUS2:(JSBubbleMessageStyle)bubbleStyle
{
    return (bubbleStyle == JSBubbleMessageStyleIncomingUS2
            || bubbleStyle == JSBubbleMessageStyleIncomingUS2Tailed
            || bubbleStyle == JSBubbleMessageStyleOutgoingUS2GreenTailed
            || bubbleStyle == JSBubbleMessageStyleOutgoingUS2Green
            || bubbleStyle == JSBubbleMessageStyleOutgoingUS2Blue
            || bubbleStyle == JSBubbleMessageStyleOutgoingUS2BlueTailed);
}

+ (CGFloat)leftOffsetForStyle:(JSBubbleMessageStyle)bubbleStyle
{
    CGFloat leftOffset = kPaddingLeftOffset;
    
    if ([JSBubbleView styleIsUS2:bubbleStyle] && ![JSBubbleView styleIsOutgoing:bubbleStyle])
    {
        leftOffset = kPaddingLeftOffsetUS2;
    }
    
    return leftOffset;
}

+ (CGFloat)topPaddingForStyle:(JSBubbleMessageStyle)bubbleStyle
{
    CGFloat topPadding = kPaddingTop;
    
    if(bubbleStyle == JSBubbleMessageStyleOutgoingUS2Green
       || bubbleStyle == JSBubbleMessageStyleOutgoingUS2GreenTailed
       || bubbleStyle == JSBubbleMessageStyleOutgoingUS2Blue
       || bubbleStyle == JSBubbleMessageStyleOutgoingUS2BlueTailed)
    {
        topPadding = kPaddingTopUS2GreenBlue;
    }
    else if([JSBubbleView styleIsUS2:bubbleStyle])
    {
        topPadding = kPaddingTopUS2;
    }
    
    return topPadding;
}

+ (UIImage *)bubbleImageForStyle:(JSBubbleMessageStyle)style
{
    switch (style) {
        case JSBubbleMessageStyleIncomingDefault:
            return [[UIImage imageNamed:@"messageBubbleGray"] stretchableImageWithLeftCapWidth:23 topCapHeight:15];
            break;
        case JSBubbleMessageStyleIncomingSquare:
            return [[UIImage imageNamed:@"bubbleSquareIncoming"] stretchableImageWithLeftCapWidth:25 topCapHeight:15];
            break;
        case JSBubbleMessageStyleOutgoingDefault:
            return [[UIImage imageNamed:@"messageBubbleBlue"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
            break;
        case JSBubbleMessageStyleOutgoingDefaultGreen:
            return [[UIImage imageNamed:@"messageBubbleGreen"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
            break;
        case JSBubbleMessageStyleOutgoingSquare:
            return [[UIImage imageNamed:@"bubbleSquareOutgoing"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
            break;
        case JSBubbleMessageStyleIncomingUS2:
        {
            UIImage *image = [UIImage imageNamed:@"chat_bubble_recipient_without_tail"];
            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(17, 26, 18, 16)];
            break;
        }
        case JSBubbleMessageStyleIncomingUS2Tailed:
        {
            UIImage *image = [UIImage imageNamed:@"chat_bubble_recipient_with_tail"];
            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(17, 26, 18, 16)];
            break;
        }
        case JSBubbleMessageStyleOutgoingUS2Blue:
        {
            UIImage *image = [UIImage imageNamed:@"chat_bubble_sender_blue_without_tail"];
            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 25)];
            break;
        }
        case JSBubbleMessageStyleOutgoingUS2BlueTailed:
        {
            UIImage *image = [UIImage imageNamed:@"chat_bubble_sender_blue_with_tail"];
            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 25)];
            break;
        }
        case JSBubbleMessageStyleOutgoingUS2Green:
        {
            UIImage *image = [UIImage imageNamed:@"chat_bubble_sender_green_without_tail"];
            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 25)];
            break;
        }
        case JSBubbleMessageStyleOutgoingUS2GreenTailed:
        {
            UIImage *image = [UIImage imageNamed:@"chat_bubble_sender_green_with_tail"];
            return [image resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 25)];
            break;
        }
    }
    
    return nil;
}

+ (UIFont *)font
{
    return [UIFont systemFontOfSize:15.0f];
}

+ (CGSize)textSizeForText:(NSString *)txt style:(JSBubbleMessageStyle)bubbleStyle 
{
    CGFloat width = [UIScreen mainScreen].applicationFrame.size.width * 0.65f;
    CGFloat height = MAX([JSBubbleView numberOfLinesForMessage:txt],
                         [txt numberOfLines]) * [JSMessageInputView textViewLineHeight];
    
    return [txt sizeWithFont:[JSBubbleView font]
           constrainedToSize:CGSizeMake(width, height)
               lineBreakMode:NSLineBreakByWordWrapping];
}

+ (CGSize)bubbleSizeForText:(NSString *)txt style:(JSBubbleMessageStyle)bubbleStyle 
{
	CGSize textSize = [JSBubbleView textSizeForText:txt style:bubbleStyle];
	return CGSizeMake(textSize.width + kBubblePaddingRight,
                      textSize.height + [JSBubbleView topPaddingForStyle:bubbleStyle] + kPaddingBottom);
}

+ (CGFloat)cellHeightForText:(NSString *)txt style:(JSBubbleMessageStyle)bubbleStyle 
{
    return [JSBubbleView bubbleSizeForText:txt style:bubbleStyle].height + kMarginTop + kMarginBottom;
}

+ (int)maxCharactersPerLine
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 33 : 109;
}

+ (int)numberOfLinesForMessage:(NSString *)txt
{
    return (txt.length / [JSBubbleView maxCharactersPerLine]) + 1;
}

@end