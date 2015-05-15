/*
 * UITetrisAppDelegate.h
 *
 * Author: Charles Magahern <charles@magahern.com>
 * Date Created: 03/28/2012
 */
 
#import <UIKit/UIKit.h>

@class UITetrisViewController;

@interface UITetrisAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITetrisViewController *tetrisViewController;

@end

