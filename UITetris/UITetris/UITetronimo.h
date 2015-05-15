/*
 * UITetronimo.h
 *
 * Author: Charles Magahern <charles@magahern.com>
 * Date Created: 03/28/2012
 */
 
#import <Foundation/Foundation.h>

#define kTetronimoBlocksRowCount 4
#define kTetronimoBlocksColCount 4
#define kTetronimoBlocksCount kTetronimoBlocksRowCount * kTetronimoBlocksColCount

typedef enum {
    UITetrisBlockColorTeal,
    UITetrisBlockColorBlue,
    UITetrisBlockColorOrange,
    UITetrisBlockColorYellow,
    UITetrisBlockColorGreen,
    UITetrisBlockColorPurple,
    UITetrisBlockColorRed
} UITetrisBlockColor;

typedef enum {
    UITetronimoTypeI = 0,
    UITetronimoTypeJ = 1,
    UITetronimoTypeL = 2,
    UITetronimoTypeO = 3,
    UITetronimoTypeS = 4,
    UITetronimoTypeT = 5,
    UITetronimoTypeZ = 6
} UITetronimoType;

// Opaque struct that defines the smallest unit of a tetronimo
typedef struct tetris_block_t {
    // We're drawing the game scene with UIImageViews, because it's significantly faster
    // than drawing the image with CoreGraphics.
    UIImageView *imageView;
    UITetrisBlockColor color;
} *UITetrisBlock;

UITetrisBlock UITetrisBlockCreate(UITetrisBlockColor);
UITetrisBlock UITetrisBlockCopy(UITetrisBlock);
void UITetrisBlockFree(UITetrisBlock);
void _checkAndInitializeImages(void);

@interface UITetronimo : NSObject {
@protected
    UITetrisBlock *_blocks;
}

@property (nonatomic, readonly, getter = blocks) UITetrisBlock *blocks;
@property (nonatomic, assign) UITetronimoType type;
@property (nonatomic, assign) int xPosition;
@property (nonatomic, assign) int yPosition;

- (id)initWithType:(UITetronimoType)type;

- (UITetrisBlock *)blocks;

- (void)rotateRight;
- (void)rotateLeft;

@end

