//
//  MJDRealmObject.m
//  Fair Dice
//
//  Created by Joan Martin on 30/04/16.
//  Copyright © 2016 Joan Martin. All rights reserved.
//

#import "MJDRealmObject.h"
#import "NSString+Additions.h"

NSString* MJDRealmObjectIdentifier(NSString *className)
{
    NSMutableString *string = [NSMutableString string];
    
    if (className.length > 0)
        [string appendFormat:@"%@::", className];
    
    [string appendString:[NSString add_uniqueString]];
    
    return [string copy];
}

@interface MJDRealmObject ()

@property (nonatomic, strong, readwrite) NSString *realmIdentifier;

@end

@implementation MJDRealmObject

+ (NSDictionary*)defaultPropertyValues
{
    return @{@"realmIdentifier": @"",
             @"realmLastUpdate": [NSDate date],
             };
}

+ (NSString*)primaryKey
{
    return @"realmIdentifier";
}

- (id)init
{
    return [self initWithIdentifier:nil];
}

- (id)initWithIdentifier:(NSString*)identifier
{
    self = [super init];
    if (self)
    {
        if (identifier.length > 0)
            self.realmIdentifier = identifier;
        else
            self.realmIdentifier = MJDRealmObjectIdentifier(NSStringFromClass(self.class));
    }
    return self;
}

@end

