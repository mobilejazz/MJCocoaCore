//
//  MJDRealmObject.h
//  Fair Dice
//
//  Created by Joan Martin on 30/04/16.
//  Copyright © 2016 Joan Martin. All rights reserved.
//

#if defined RLM_ARRAY_TYPE
#import <Realm/Realm.h>

@interface MJDRealmObject : RLMObject

/**
 * Main initializer.
 **/
- (id)initWithIdentifier:(NSString*)identifier;

/**
 * A unique identifier of the object (PrimaryKey).
 **/
@property (nonatomic, strong, readonly) NSString *realmIdentifier;

/**
 * Object update date.
 **/
@property (nonatomic, strong) NSDate *realmLastUpdate;

@end
#endif
