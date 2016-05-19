//
//  MJDRealmMapper.h
//  Fair Dice
//
//  Created by Joan Martin on 30/04/16.
//  Copyright © 2016 Joan Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined RLM_ARRAY_TYPE
#import <Realm/Realm.h>

@class MJDEntity;
@class MJDRealmObject;

@protocol MJDRealmMapper <NSObject>

/**
 * Maps a realm object to an entity.
 * @param realmObject The object to map.
 * @return The mapped entity.
 **/
- (__kindof MJDEntity *)entityFromRealmObject:(__kindof MJDRealmObject *)realmObject;

/**
 * Maps an entity to a realm object.
 * @param entity The entity to map.
 * @param realm The realm database.
 * @return The mapped realm object.
 **/
- (__kindof MJDRealmObject *)realmObjectFromEntity:(__kindof MJDEntity *)entity realm:(RLMRealm*)realm;

@end

/**
 * Converts an RLMArray into an NSArray of entities.
 **/
static inline NSArray<__kindof MJDEntity*>* MJDEntitiesArrayFromRealmArray(RLMArray *array, id <MJDRealmMapper> mapper)
{
    if (array.count == 0 || mapper == nil)
        return nil;
    
    NSMutableArray <__kindof MJDEntity*> *entities = [NSMutableArray array];
    for (NSInteger i=0; i<array.count; ++i)
    {
        MJDRealmObject *object = (id)[array objectAtIndex:i];
        MJDEntity *entity = [mapper entityFromRealmObject:object];
        [entities addObject:entity];
    }
    
    return [entities copy];
}

static inline RLMArray* RealmArrayFromMJDEntitiesArray(NSArray <__kindof MJDEntity*> *entities, id <MJDRealmMapper> mapper, Class realmClass, RLMRealm *realm)
{
    RLMArray *array = (id)[[RLMArray alloc] initWithObjectClassName:NSStringFromClass(realmClass)];
    
    [entities enumerateObjectsUsingBlock:^(MJDEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MJDRealmObject *object = [mapper realmObjectFromEntity:obj realm:realm];
        [array addObject:(id)object];
    }];
    
    return array;
}
#endif
