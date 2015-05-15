/*
 * main.m
 *
 * Author: Charles Magahern <charles@magahern.com>
 * Date Created: 03/28/2012
 */
 
#import <UIKit/UIKit.h>
#import "UITetrisAppDelegate.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([UITetrisAppDelegate class]));
    [pool release];
    return retVal;
}

