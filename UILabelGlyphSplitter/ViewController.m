//
//  ViewController.m
//  UILabelGlyphSplitter
//
//  Created by admin on 19/04/15.
//  Copyright (c) 2015 corsarus. All rights reserved.
//

#import "ViewController.h"
#import "SplitLabel.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet SplitLabel *splitLabel;

@end

@implementation ViewController


- (void)viewDidLayoutSubviews
{
    NSArray *glyphTextLayers = [self.splitLabel glyphLayers];
    
    for (int i = 0; i < glyphTextLayers.count; i++) {
        CATextLayer *textLayer = glyphTextLayers[i];
        
        if (i % 2 == 0)
            textLayer.position = CGPointMake(textLayer.position.x, CGRectGetMidY(textLayer.bounds) + CGRectGetHeight(textLayer.bounds)  /  4);
        else
            textLayer.position = CGPointMake(textLayer.position.x, CGRectGetMidY(textLayer.bounds) - CGRectGetHeight(textLayer.bounds)  /  4);

    }
    
}

@end	
