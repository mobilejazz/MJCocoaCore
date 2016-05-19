//
// Copyright 2015 Mobile Jazz SL
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


#import "MJObjectStack.h"

@implementation MJObjectStack
{
    NSMutableArray <NSString*> *_stack;
    NSMapTable <NSString*, id <MJObjectStackIdentity>> *_mapTable;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _stack = [NSMutableArray array];
        _mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

#pragma mark Public Methods

- (void)push:(nonnull id <MJObjectStackIdentity>)object
{
    [self mjz_updateStackFromDeallocatedObjects];
    
    @synchronized(self)
    {
        NSString *key = [object objectStackIdentity];
        
        [_stack addObject:key];
        [_mapTable setObject:object forKey:key];
    }
}

- (void)pop
{
    [self mjz_updateStackFromDeallocatedObjects];
    
    @synchronized(self)
    {
        NSString *key = [_stack lastObject];
        
        if (key)
        {
            [_mapTable removeObjectForKey:key];
            [_stack removeLastObject];
        }
    }
}

- (nullable id <MJObjectStackIdentity>)top
{
    [self mjz_updateStackFromDeallocatedObjects];
    
    @synchronized(self)
    {
        NSString *key = [_stack lastObject];
        
        if (key)
            return [_mapTable objectForKey:key];
    }
    
    return nil;
}

- (void)remove:(nonnull id <MJObjectStackIdentity>)object
{
    [self mjz_updateStackFromDeallocatedObjects];
    
    @synchronized(self)
    {
        NSString *key = [object objectStackIdentity];
        
        if ([_mapTable objectForKey:key])
        {
            [_stack removeObject:key];
            [_mapTable removeObjectForKey:key];
        }
    }
}

- (BOOL)isTop:(nonnull id <MJObjectStackIdentity>)object
{
    id <MJObjectStackIdentity> top = self.top;
    NSString *key1 = [top objectStackIdentity];
    NSString *key2 = [object objectStackIdentity];
    
    return [key1 isEqualToString:key2];
}

- (BOOL)contains:(nonnull id <MJObjectStackIdentity>)object
{
    NSString *key = [object objectStackIdentity];
    return [_stack containsObject:key];
}

#pragma mark Private Methods

- (void)mjz_updateStackFromDeallocatedObjects
{
    @synchronized(self)
    {
        if (_stack.count == _mapTable.count)
            return;
        
        NSArray <NSString*> *stack = [_stack copy];
        [stack  enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![_mapTable objectForKey:obj])
                [_stack removeObject:obj];
        }];
    }
}

@end


@implementation NSString (MJObjectStack)

- (NSString *)objectStackIdentity
{
    return self;
}

@end

@implementation NSNumber (MJObjectStack)

- (NSString *)objectStackIdentity
{
    return [NSString stringWithFormat:@"%@", self];
}

@end
