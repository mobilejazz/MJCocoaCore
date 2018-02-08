//
// Copyright 2018 Mobile Jazz SL
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

#import "UIDevice+Additions.h"

#define COMPARISON_BETWEEN_CURRENT_OS_AND(v) [[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch]

@implementation UIDevice (Additions)

#pragma mark - Greater than

+ (BOOL)isOSVersionGreaterOrEqualThan:(NSString *)version
{
    return (COMPARISON_BETWEEN_CURRENT_OS_AND(version) != NSOrderedAscending);
}

+ (BOOL)isOSVersionGreaterThan:(NSString *)version
{
    return (COMPARISON_BETWEEN_CURRENT_OS_AND(version) == NSOrderedDescending);
}

#pragma mark - Lower than

+ (BOOL)isOSVersionLowerOrEqualThan:(NSString *)version
{
    return (COMPARISON_BETWEEN_CURRENT_OS_AND(version) != NSOrderedDescending);
}

+ (BOOL)isOSVersionLowerThan:(NSString *)version
{
    return (COMPARISON_BETWEEN_CURRENT_OS_AND(version) == NSOrderedAscending);
}

#pragma mark - equal to

+ (BOOL)isOSVersionEqualTo:(NSString *)version
{
    return (COMPARISON_BETWEEN_CURRENT_OS_AND(version) == NSOrderedSame);
}

@end
