//
//  VGInstanceDumper.m
//  VG
//
//  Created by Håvard Fossli on 22.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "VGInstanceDumper.h"

@interface VGEncodeType ()

@property (nonatomic, strong) NSString *string;

@end

@implementation VGEncodeType

+ (id)createWithString:(NSString *)string
{
    VGEncodeType *instance = [VGEncodeType new];
    instance.string = string;
    return instance;
}

+ (id)createWithUTF8String:(const char *)utf8string
{
    return [self createWithString:[NSString stringWithUTF8String:utf8string]];
}

- (BOOL)isCGPoint
{
    return [self.string hasPrefix:@"{CGPoint="];
}

- (BOOL)isCGRect
{
    return [self.string hasPrefix:@"{CGRect="];
}

- (BOOL)isCGSize
{
    return [self.string hasPrefix:@"{CGSize="];
}

@end

@interface VGInstanceDumper ()

// private properties and methods

@end

@implementation VGInstanceDumper

#pragma mark - Construct and destruct

+ (NSArray *)classesForInstance:(id)instance asStrings:(BOOL)asStrings
{
    NSMutableArray *classes = [NSMutableArray array];
    Class class = [instance class];
    
    while (class)
    {
        if(asStrings)
            [classes addObject:NSStringFromClass(class)];
        else
            [classes addObject:(id)class];
        
        class = [class superclass];
    }
    
    return classes;
}

+ (void)iterateOverClassesOfInstance:(id)instance block:(void(^)(Class class, BOOL *stop))block
{
    Class class = [instance class];
    BOOL stop = NO;
    while (class && !stop)
    {        
        Class class = [class superclass];
        block(class, &stop);
    }
}

+ (void)iterateOverPropertiesInInstance:(id)instance ofClass:(Class)class block:(void(^)(objc_property_t property, NSString *propertyName, id propertyValue, VGEncodeType *encodeType, BOOL *stop))block
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    BOOL stop = NO;
    for (i = 0; i < outCount && !stop; i++)
    {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        id propertyValue = [instance valueForKey:(NSString *)propertyName];
        
        // NSLog(@"propertyName: %@, propertyValue: %@", propertyName, propertyValue);
        
        unsigned int attributesCount;
        objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributesCount);
        
        // for(int i = 0; i < attributesCount; i++)
        // {
        //     objc_property_attribute_t attribute = attributes[i];
        //     NSString *attributeName = [NSString stringWithUTF8String:attribute.name];
        //     NSString *attributeValue = [NSString stringWithUTF8String:attribute.value];
        //     NSLog(@"attributeName: %@, attributeValue: %@", attributeName, attributeValue);
        // }
        
        VGEncodeType *encodeType = [VGEncodeType createWithUTF8String:attributes[0].value];
        free(attributes);
        
        block(property, propertyName, propertyValue, encodeType, &stop);
    }
    free(properties);
}

+ (NSDictionary *)metaInfoForInstance:(id)instance
{
    return @{
    @"classes": [self classesForInstance:instance asStrings:YES],
    @"pointer": [NSString stringWithFormat:@"%p", instance]
    };
}

+ (NSMutableDictionary *)dumpPropertiesOfInstance:(id)instance
{
    return [self dumpPropertiesOfInstance:instance parseBlock:nil];
}

+ (NSMutableDictionary *)dumpPropertiesOfInstance:(id)instance parseBlock:(id(^)(objc_property_t property, NSString *propertyName, VGEncodeType *encodeType, id propertyValue))parseBlock
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *classes = [self classesForInstance:instance asStrings:NO];
    dictionary[@"metaInfo"] = [self metaInfoForInstance:instance];
    
    for(Class class in classes)
    {
        [self iterateOverPropertiesInInstance:instance ofClass:class block:^(objc_property_t property,  NSString *propertyName, id propertyValue, VGEncodeType *encodeType, BOOL *stop) {
            
            id value = parseBlock ? parseBlock(property, propertyName, propertyValue, encodeType) : propertyValue;
            
            if(value != nil)
            {
                dictionary[propertyName] = value;
            }
        }];
    }
    
    return dictionary;
}

@end
