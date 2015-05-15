/*
 * UITetrisView.m
 *
 * Author: Charles Magahern <charles@magahern.com>
 * Date Created: 03/28/2012
 */
 
#import "UITetrisView.h"
#import "UITetrisGame.h"

#define kDefaultBlockSize 15.0
#define kNextTetronimoBlockTag 1337


@interface UITetrisView ()

- (void)_drawBlock:(UITetrisBlock)block atXPosition:(int)xPos yPosition:(int)yPos;
- (void)_drawBlock:(UITetrisBlock)block atBoardPosition:(int)position;
- (void)_drawBlocks;
- (void)_drawFallingTetronimo;

@end

@implementation UITetrisView
@synthesize game;
@synthesize blockSize;
@synthesize boardIsDirty;

- (void)initialize
{
    [self setBackgroundColor:[UIColor blackColor]];
    
    self.blockSize = kDefaultBlockSize;
    self.boardIsDirty = YES;
}

- (id)init
{
    if ((self = [super init])) [self initialize];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) [self initialize];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
        
        // Add Background
        UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tetris_board.png"]];
        bg.frame = CGRectMake(0.0, 0.0, bg.frame.size.width, bg.frame.size.height);
        [self insertSubview:bg atIndex:0];
        [bg release];
        
        
        // Add Game Board
        CGFloat boardWidth = blockSize * kTetrisBoardColBlocksCount;
        CGFloat boardHeight = blockSize * kTetrisBoardRowBlocksCount;
        CGRect gameBoardRect = CGRectMake(frame.size.width / 8.0 + 3.0,
                                    frame.size.height / 2.0 - boardHeight / 2.0 + 25.0,
                                    boardWidth, boardHeight);
        _gameBoardView = [[UIView alloc] initWithFrame:gameBoardRect];
        _gameBoardView.clipsToBounds = YES;
        [self addSubview:_gameBoardView];
        
        
        // Add Score Label
        _scoreLabel = [[UILabel alloc] init];
        _scoreLabel.textAlignment = UITextAlignmentCenter;
        _scoreLabel.font = [UIFont boldSystemFontOfSize:32.0];
        _scoreLabel.textColor = [UIColor whiteColor];
        _scoreLabel.backgroundColor = [UIColor clearColor];
        _scoreLabel.text = @"000";
        [_scoreLabel sizeToFit];
        _scoreLabel.center = CGPointMake(241.0, 375.0);
        [self addSubview:_scoreLabel];
        
        // Add Next Tetronimo Display
        CGFloat nextWidth = blockSize * 4 + 20.0;
        CGFloat nextHeight = (blockSize / 2.0) * 4 + 20.0;
        CGRect nextDisplayRect = CGRectMake(self.bounds.size.width - self.bounds.size.width / 8.0 - nextWidth,
                                            gameBoardRect.origin.y,
                                            nextWidth, nextHeight);
        _nextTetronimoView = [[UIView alloc] initWithFrame:nextDisplayRect];
        _nextTetronimoView.clipsToBounds = YES;
        _nextTetronimoContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, nextDisplayRect.size.width, nextDisplayRect.size.height)];
        [_nextTetronimoView addSubview:_nextTetronimoContentView];
        [self addSubview:_nextTetronimoView];
    }
    return self;
}

- (void)dealloc
{
    [game release];
    
    [_gameBoardView release];
    [_scoreLabel release];
    [_nextTetronimoView release];
    [_nextTetronimoContentView release];
    
    [super dealloc];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    _scoreLabel.text = @"0";
    [self updateNextTetronimoDisplay:[game nextTetronimo]];
}


#pragma mark - Displaying Game State

- (void)updateNextTetronimoDisplay:(UITetronimo *)tetronimo
{
    if (!_nextTetronimoView || !_nextTetronimoContentView) return;
    
    UITetrisBlock *blocks = [tetronimo blocks];
    
    [UIView animateWithDuration:0.1 animations:^(void) {
        _nextTetronimoContentView.transform = CGAffineTransformMakeTranslation(0.0, -_nextTetronimoContentView.bounds.size.height);
    } completion:^(BOOL f) {
        if (f) {
            // Remove the old tetronimo block images.
            for (UIImageView *oldImageView in _nextTetronimoContentView.subviews) {
                if (oldImageView.tag == kNextTetronimoBlockTag) {
                    [oldImageView removeFromSuperview];
                }
            }
            
            CGFloat tetWidth, tetHeight, blkXOffset, blkYOffset;
            CGPoint nextTetOrigin;
            
            tetWidth    = blockSize * (tetronimo.type == UITetronimoTypeI ? 4 : 3);
            tetHeight   = blockSize * (tetronimo.type == UITetronimoTypeI ? 1 : 2);
            nextTetOrigin = CGPointMake(_nextTetronimoView.bounds.size.width / 2.0 - tetWidth / 2.0,
                                                _nextTetronimoView.bounds.size.height / 2.0 - tetHeight / 2.0);
            blkXOffset = (tetronimo.type == UITetronimoTypeI ? 0.0 : (tetronimo.type == UITetronimoTypeO ? -0.5 : -1.0));
            blkYOffset = -1.0;
            for (unsigned i = 0; i < kTetronimoBlocksCount; i++) {
                if (blocks[i] != NULL) {
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:[blocks[i]->imageView image]];
                    imageView.frame = CGRectMake(nextTetOrigin.x + ((i % kTetronimoBlocksColCount) + blkXOffset) * blockSize,
                                                 nextTetOrigin.y + ((i / kTetronimoBlocksColCount) + blkYOffset) * blockSize,
                                                 blockSize, blockSize);
                    imageView.tag = kNextTetronimoBlockTag;
                    [_nextTetronimoContentView addSubview:imageView];
                    [imageView release];
                }
            }
            
            _nextTetronimoContentView.transform = CGAffineTransformMakeTranslation(0.0, _nextTetronimoContentView.bounds.size.height);
            [UIView animateWithDuration:0.1 animations:^(void) {
                _nextTetronimoContentView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
            }];
        }
    }];
}

- (void)setScore:(NSUInteger)score
{
    [_scoreLabel setText:[NSString stringWithFormat:@"%d", score]];
}

- (void)animateClearLinesAtRows:(NSUInteger[])rows count:(NSUInteger)count
{
    UIView *animationView;
    CGFloat posY;
    for (unsigned i = 0; i < count; i++) {
        posY = rows[i] * blockSize;
        animationView = [[UIView alloc] initWithFrame:CGRectMake(0.0, posY, _gameBoardView.bounds.size.width, blockSize)];
        animationView.backgroundColor = [UIColor whiteColor];
        animationView.alpha = 0.0;
        
        [_gameBoardView addSubview:animationView];
        
        [UIView animateWithDuration:0.08 animations:^(void) {
            animationView.alpha = 1.0;
        } completion:^(BOOL f) {
            if (f) {
                [UIView animateWithDuration:0.1 animations:^(void) {
                    animationView.transform = CGAffineTransformMakeScale(1.5, 1.5);
                    animationView.alpha = 0.0;
                } completion:^(BOOL f) {
                    if (f) {
                        [animationView removeFromSuperview];
                        [animationView release];
                    }
                }];
            }
        }];
    }
}


#pragma mark - "Drawing" Methods

- (void)_drawBlock:(UITetrisBlock)block atXPosition:(int)xPos yPosition:(int)yPos
{
    if (block == NULL) return;
    
    CGFloat drawX, drawY;
    CGRect blockRect;
    
    drawX = xPos * blockSize;
    drawY = yPos * blockSize;
    blockRect = CGRectMake(drawX, drawY, blockSize, blockSize);
    
    if (block->imageView != nil) {
        // Make sure that we don't set the frame if we don't need to
        if (block->imageView.frame.origin.x != drawX || block->imageView.frame.origin.y != drawY)
            block->imageView.frame = blockRect;
        
        // Make sure that the block image isn't already on our game board
        if (block->imageView.superview == nil)
            [_gameBoardView addSubview:block->imageView];
    }
}

- (void)_drawBlock:(UITetrisBlock)block atBoardPosition:(int)position
{
    int xPos, yPos;
    xPos = position % kTetrisBoardColBlocksCount;
    yPos = position / kTetrisBoardColBlocksCount;
    
    [self _drawBlock:block atXPosition:xPos yPosition:yPos];
}

- (void)_drawBlocks
{
    UITetrisBlock *blocks = [game gameBoard];
    
    for (unsigned i = 0; i < kTetrisBoardSize; i++) {
        if (blocks[i] != NULL)
            [self _drawBlock:blocks[i] atBoardPosition:i];
    }
    
    self.boardIsDirty = NO;
}

- (void)_drawFallingTetronimo
{
    UITetronimo *tet = [game fallingTetronimo];
    UITetrisBlock *tetblocks = [tet blocks];
    int xPos, yPos;
    
    if (tet == nil)
        return;
    
    for (unsigned i = 0; i < kTetronimoBlocksCount; i++) {
        if (tetblocks[i] != NULL) {
            xPos = tet.xPosition + (i % kTetronimoBlocksColCount);
            yPos = tet.yPosition + (i / kTetronimoBlocksColCount);
            
            [self _drawBlock:tetblocks[i] atXPosition:xPos yPosition:yPos];
        }
    }
}

- (void)redraw
{
    [self _drawFallingTetronimo];
    
    if (boardIsDirty)
        [self _drawBlocks];
}


@end

