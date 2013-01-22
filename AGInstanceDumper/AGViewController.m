//
//  AGViewController.m
//  AGInstanceDumper
//
//  Created by Håvard Fossli on 22.01.13.
//  Copyright (c) 2013 Håvard Fossli. All rights reserved.
//

#import "AGViewController.h"
#import "VGInstanceDumper.h"
#import "SBJSON.h"
#import "NSObject+SBJSON.h"

@interface AGViewController ()

@end

@implementation AGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerDidChange:)];
        [self.view addGestureRecognizer:recognizer];
        recognizer.delegate = self;
    }
    {
        UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerDidChange:)];
        [self.view addGestureRecognizer:recognizer];
        recognizer.delegate = self;
    }
}

- (NSTimeInterval)timeSpentWhilePerformingBlock:(void(^)(void))block
{
    NSTimeInterval timeStamp = CACurrentMediaTime();
    block();
    NSTimeInterval timeSpent = CACurrentMediaTime() - timeStamp;
    return timeSpent;
}

- (void)gestureRecognizerDidChange:(UIGestureRecognizer *)recognizer
{
    __block NSMutableDictionary *dump;
    [self timeSpentWhilePerformingBlock:^{
        dump = [self dumpStateOfRecognizer:recognizer];
    }];
    
    // NSString *jsonString = [dump JSONRepresentation];
    
    // NSLog(@"Time spent getting state of recognizer: %f", timeSpent);
    
    // NSLog(@"recognizerDidChange %@", jsonString);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    __block NSMutableDictionary *dump;
    [self timeSpentWhilePerformingBlock:^{
        dump = [self dumpStateOfRecognizer:recognizer];
    }];
    NSString *jsonString = [dump JSONRepresentation];
    
    NSLog(@"gestureRecognizerShouldBegin %@", jsonString);
    
    return YES;
}

- (NSMutableDictionary *)dumpStateOfRecognizer:(UIGestureRecognizer *)recognizer
{
    NSMutableDictionary *dict = [VGInstanceDumper dumpPropertiesOfInstance:recognizer parseBlock:^id(objc_property_t property, NSString *propertyName, id propertyValue, VGEncodeType *encodeType) {
        if([encodeType isCGPoint])
        {
            CGPoint point = [propertyValue CGPointValue];
            return @{@"x": @(point.x), @"y": @(point.y)};
        }
        else if([encodeType isCGRect])
        {
            CGRect rect = [propertyValue CGRectValue];
            return @{
                @"size": @{
                    @"width": @(rect.size.width),
                    @"height": @(rect.size.height)
                },
                @"origin": @{
                    @"x": @(rect.origin.x),
                    @"y": @(rect.origin.y)
                }
            };
        }
        else if([encodeType isCGRect])
        {
            CGSize size = [propertyValue CGSizeValue];
            return @{@"width": @(size.width), @"height": @(size.height)};
        }
        else if(![propertyValue isKindOfClass:[NSNumber class]] && ![propertyValue isKindOfClass:[NSString class]])
        {
            return nil;
        }
        return propertyValue;
    }];
    return dict;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
