//
//  VGInstanceDumper.h
//  VG
//
//  Created by Håvard Fossli on 22.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface VGEncodeType : NSObject

+ (id)createWithString:(NSString *)string;
+ (id)createWithUTF8String:(const char *)utf8string;

- (BOOL)isCGPoint;
- (BOOL)isCGRect;
- (BOOL)isCGSize;

@end

// for further research we could look more into this document https://github.com/limneos/weak_classdump/blob/master/weak_classdump.cy

@interface VGInstanceDumper : NSObject {}

+ (void)iterateOverPropertiesInInstance:(id)instance ofClass:(Class)class block:(void(^)(objc_property_t property, NSString *propertyName, id propertyValue, VGEncodeType *encodeType, BOOL *stop))block;

+ (NSMutableDictionary *)dumpPropertiesOfInstance:(id)instance;

+ (NSMutableDictionary *)dumpPropertiesOfInstance:(id)instance parseBlock:(id(^)(objc_property_t property, NSString *propertyName, VGEncodeType *encodeType, id propertyValue))parseBlock;

@end

#pragma mark - Example of usage

/*
- (NSDictionary *)dumpStateOfRecognizer:(UIGestureRecognizer *)recognizer
{
    NSDictionary *dict = [VGInstanceDumper dumpPropertiesOfInstance:recognizer parseBlock:^id(objc_property_t property, NSString *propertyName, id propertyValue, VGEncodeType *encodeType) {
        if([encodeType isCGPoint])
        {
            CGPoint point = [propertyValue CGPointValue];
            return @{@"x": @(point.x), @"y": @(point.y)};
        }
        else if([encodeType isCGRect])
        {
            CGRect rect = [propertyValue CGRectValue];
            return @{@"width": @(rect.size.width), @"height": @(rect.size.height), @"x": @(rect.origin.x), @"y": @(rect.origin.y)};
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
*/