//
// Copyright 2017 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MJDRealmObject.h"
#import "NSString+Additions.h"

NSString* MJDRealmObjectIdentifier(NSString *className)
{
    return [[NSUUID UUID] UUIDString];
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

