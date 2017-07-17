//
// Copyright 2016 Mobile Jazz SL
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

#import <Realm/Realm.h>

/**
 * A realm factory.
 **/
@interface MJDRealmFactory : NSObject

/**
 * Default initializer.
 * @param nameOrURLPath The name of the realm database file or a FileURL string pointing to the file location. Cannot be nil nor empty.
 * @param encryptionKeyName The name of the encryption key. Pass nil if no encryption is required.
 * @return The initialized instance.
 * @disussion If name, then the file will be located in the Documents directory.
 **/
- (instancetype)initWithName:(NSString*)nameOrURLPath encryptionKeyName:(NSString *)encryptionKeyName;

/**
 * Default initializer.
 * @param nameOrURLPath The name of the realm database file. Cannot be nil nor empty.
 * @param encryptionKeyName The name of the encryption key. Pass nil if no encryption is required.
 * @param inMemory YES if the database is stored in memory, NO if in the file system.
 * @disussion If name and inMemory == NO, then the file will be located in the Documents directory.
 **/
- (instancetype)initWithName:(NSString*)nameOrURLPath encryptionKeyName:(NSString *)encryptionKeyName inMemory:(BOOL)inMemory;

/**
 * @property The database name.
 **/
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The encryption key name.
 **/
@property (nonatomic, copy, readonly) NSString *encryptionKeyName;

/**
 * Sets the objects managed by the realm instance. If the method is not called, the realm will be configured with all realm classes available in the obj-c runtime.
 * @param realmClasses An array of realm object classes.
 **/
- (void)setRealmClasses:(NSArray <Class> *)realmClasses;

/**
 * Sets the realm schema version.
 **/
- (void)setRealmSchemaVersion:(uint64_t)schemaVersion;

/**
 * Sets the minimjum realm schmea version from which migrations can be done.
 **/
- (void)setMinimumValidMigrationSchemaVersion:(uint64_t)minimumValidMigrationSchemaVersion;

/**
 * Sets the realm migration block.
 **/
- (void)setRealmMigrationBlock:(RLMMigrationBlock)migrationBlock;

/**
 * Returns the realm file path.
 **/
- (NSString*)realmFilePath;

/**
 * Returns a new realm instance.
 **/
- (RLMRealm*)realmInstance;

@end
