/*
 * UITetronimo.m
 *
 * Author: Charles Magahern <charles@magahern.com>
 * Date Created: 03/28/2012
 */
 
#import "UITetronimo.h"

static const unsigned iBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    1, 1, 1, 1,
    0, 0, 0, 0,
    0, 0, 0, 0
};

static const unsigned jBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    0, 1, 0, 0,
    0, 1, 1, 1,
    0, 0, 0, 0
};

static const unsigned lBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    0, 0, 0, 1,
    0, 1, 1, 1,
    0, 0, 0, 0
};

static const unsigned oBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    0, 1, 1, 0,
    0, 1, 1, 0,
    0, 0, 0, 0
};

static const unsigned sBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    0, 0, 1, 1,
    0, 1, 1, 0,
    0, 0, 0, 0
};

static const unsigned tBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    0, 0, 1, 0,
    0, 1, 1, 1,
    0, 0, 0, 0
};

static const unsigned zBlock[kTetronimoBlocksCount] = {
    0, 0, 0, 0,
    0, 1, 1, 0,
    0, 0, 1, 1,
    0, 0, 0, 0
};

static UIImage *purpleBlockImg  = nil;
static UIImage *yellowBlockImg  = nil;
static UIImage *tealBlockImg    = nil;
static UIImage *redBlockImg     = nil;
static UIImage *greenBlockImg   = nil;
static UIImage *orangeBlockImg  = nil;
static UIImage *blueBlockImg    = nil;


UITetrisBlock UITetrisBlockCreate(UITetrisBlockColor col)
{
    UITetrisBlock blk = (UITetrisBlock) malloc(sizeof(struct tetris_block_t));
    blk->color = col;
    
    _checkAndInitializeImages();
    
    UIImage *image = nil;
    switch (col) {
        case UITetrisBlockColorTeal:
            image = tealBlockImg;
            break;
        case UITetrisBlockColorBlue:
            image = blueBlockImg;
            break;
        case UITetrisBlockColorOrange:
            image = orangeBlockImg;
            break;
        case UITetrisBlockColorYellow:
            image = yellowBlockImg;
            break;
        case UITetrisBlockColorGreen:
            image = greenBlockImg;
            break;
        case UITetrisBlockColorPurple:
            image = purpleBlockImg;
            break;
        case UITetrisBlockColorRed:
            image = redBlockImg;
            break;
        default:
            break;
    }
    
    blk->imageView = [[UIImageView alloc] initWithImage:image];
    
    return blk;
}

UITetrisBlock UITetrisBlockCopy(UITetrisBlock blk)
{
    UITetrisBlock new_blk = (UITetrisBlock) malloc(sizeof(struct tetris_block_t));
    new_blk->color = blk->color;
    new_blk->imageView = [blk->imageView retain];

    return new_blk;
}

void UITetrisBlockFree(UITetrisBlock blk)
{
    if (blk != NULL) {
        [blk->imageView removeFromSuperview];
        [blk->imageView release];
        free(blk);
    }
}

void _checkAndInitializeImages(void)
{
    BOOL loadedAlready = YES;
    loadedAlready &= purpleBlockImg != nil;
    loadedAlready &= yellowBlockImg != nil;
    loadedAlready &= tealBlockImg != nil;
    loadedAlready &= redBlockImg != nil;
    loadedAlready &= greenBlockImg != nil;
    loadedAlready &= orangeBlockImg != nil;
    loadedAlready &= blueBlockImg != nil;
    
    if (!loadedAlready) {
        purpleBlockImg  = [[UIImage imageNamed:@"block_purple.png"] retain];
        yellowBlockImg  = [[UIImage imageNamed:@"block_yellow.png"] retain];
        tealBlockImg    = [[UIImage imageNamed:@"block_teal.png"] retain];
        redBlockImg     = [[UIImage imageNamed:@"block_red.png"] retain];
        greenBlockImg   = [[UIImage imageNamed:@"block_green.png"] retain];
        orangeBlockImg  = [[UIImage imageNamed:@"block_orange.png"] retain];
        blueBlockImg    = [[UIImage imageNamed:@"block_blue.png"] retain];
    }
}


@implementation UITetronimo
@synthesize type;
@synthesize xPosition, yPosition;

- (id)init
{
    if ((self = [super init])) {
        _blocks = (UITetrisBlock *) malloc(kTetronimoBlocksCount * sizeof(struct tetris_block_t));
        
        type = 0;
        xPosition = yPosition = 0;
    }
    
    return self;
}

- (id)initWithType:(UITetronimoType)t
{
    if ((self = [self init])) {
        unsigned *blks;
        UITetrisBlockColor color;
        
        switch (t) {
            case UITetronimoTypeI:
                blks = (unsigned *) iBlock;
                color = UITetrisBlockColorTeal;
                break;
            case UITetronimoTypeJ:
                blks = (unsigned *) jBlock;
                color = UITetrisBlockColorBlue;
                break;
            case UITetronimoTypeL:
                blks = (unsigned *) lBlock;
                color = UITetrisBlockColorOrange;
                break;
            case UITetronimoTypeO:
                blks = (unsigned *) oBlock;
                color = UITetrisBlockColorYellow;
                break;
            case UITetronimoTypeS:
                blks = (unsigned *) sBlock;
                color = UITetrisBlockColorGreen;
                break;
            case UITetronimoTypeT:
                blks = (unsigned *) tBlock;
                color = UITetrisBlockColorPurple;
                break;
            case UITetronimoTypeZ:
                blks = (unsigned *) zBlock;
                color = UITetrisBlockColorRed;
                break;
            default:
                blks = (unsigned *) tBlock;
                color = UITetrisBlockColorPurple;
                break;
        }
        
        self.type = t;
        
        for (unsigned i = 0; i < kTetronimoBlocksCount; i++) {
            _blocks[i] = (blks[i] ? UITetrisBlockCreate(color) : NULL);
        }
    }
    
    return self;
}

- (void)dealloc
{
    for (unsigned i = 0; i < kTetronimoBlocksCount; i++)
        UITetrisBlockFree(_blocks[i]);
    free(_blocks);
    
    [super dealloc];
}


#pragma mark - Accessors

- (UITetrisBlock *)blocks
{
    return _blocks;
}


#pragma mark - Rotation Methods

- (void)rotateRight
{
    UITetrisBlock blks[kTetronimoBlocksCount];
    for (unsigned i = 0; i < kTetronimoBlocksCount; i++) {
        unsigned row, col;
        row = (kTetronimoBlocksRowCount - 1) - (i % kTetronimoBlocksColCount);
        col = i / kTetronimoBlocksColCount;
        
        // newRow * kTetronimoBlocksColCount + newCol
        blks[i] = _blocks[row * kTetronimoBlocksColCount + col];
    }
    
    memcpy(_blocks, blks, kTetronimoBlocksCount * sizeof(unsigned));
}

- (void)rotateLeft
{
    UITetrisBlock blks[kTetronimoBlocksCount];
    for (unsigned i = 0; i < kTetronimoBlocksCount; i++) {
        unsigned row, col;
        row = i % kTetronimoBlocksColCount;
        col = kTetronimoBlocksColCount - i / kTetronimoBlocksColCount - 1;
        
        // newRow * kTetronimoBlocksColCount + newCol
        blks[i] = _blocks[row * kTetronimoBlocksColCount + col];
    }
    
    memcpy(_blocks, blks, kTetronimoBlocksCount * sizeof(unsigned));
}


@end

