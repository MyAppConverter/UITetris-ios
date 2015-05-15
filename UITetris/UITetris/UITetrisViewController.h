/*
 * UITetrisViewController.h
 *
 * Author: Charles Magahern <charles@magahern.com>
 * Date Created: 03/28/2012
 */
 
#import "UITetrisGame.h"
#import <AVFoundation/AVFoundation.h>

@interface UITetrisViewController : UIViewController<UITetrisGameDelegate, UIAlertViewDelegate> {
    UITetrisGame *tetrisGame;
    AVAudioPlayer *musicPlayer;
    
@private
    CGFloat _touchDistanceMoved;
}

@end

