/*
 * UITetrisView.h
 *
 * Author: Charles Magahern <charles@magahern.com>
 * Date Created: 03/28/2012
 */
 
#import <UIKit/UIKit.h>

@class UITetrisGame;
@class UITetronimo;
@interface UITetrisView : UIView {
@private
    UIView *_gameBoardView;
    UIView *_nextTetronimoView;
    UIView *_nextTetronimoContentView;
    UILabel *_scoreLabel;
}

@property (nonatomic, retain) UITetrisGame *game;
@property (nonatomic, assign) CGFloat blockSize;
@property (nonatomic, assign) BOOL boardIsDirty;

- (void)redraw;
- (void)updateNextTetronimoDisplay:(UITetronimo *)tetronimo;
- (void)setScore:(NSUInteger)score;
- (void)animateClearLinesAtRows:(NSUInteger[])rows count:(NSUInteger)count;

@end

