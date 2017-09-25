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

#import "MJDRealmFactory.h"
#import "MJSecureKey.h"

@implementation MJDRealmFactory
{
    RLMRealmConfiguration *_configuration;
    uint64_t _minimumValidMigrationSchemaVersion;
    BOOL _isValidated;
}

- (instancetype)initWithName:(id)nameOrURLPathOrFileURL encryptionKeyName:(NSString *)encryptionKeyName
{
    return [self initWithName:nameOrURLPathOrFileURL encryptionKeyName:encryptionKeyName inMemory:NO];
}

- (instancetype)initWithName:(id)nameOrURLPathOrFileURL encryptionKeyName:(NSString *)encryptionKeyName inMemory:(BOOL)inMemory
{
    if (nameOrURLPathOrFileURL == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"<name> cannot be nil."
                                     userInfo:nil];
    }
    
    if ([nameOrURLPathOrFileURL isKindOfClass:NSString.class])
    {
        if ([nameOrURLPathOrFileURL length] == 0)
        {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"<name> cannot be an empty string."
                                         userInfo:nil];
        }
    }
    
    self = [super init];
    if (self)
    {
        _name = nameOrURLPathOrFileURL;
        _encryptionKeyName = encryptionKeyName;
        
        _minimumValidMigrationSchemaVersion = RLMNotVersioned;
        
        _configuration = [[RLMRealmConfiguration alloc] init];
        
        if (inMemory)
        {
            _configuration.inMemoryIdentifier = _name;
        }
        else
        {
            NSURL *url = nil;
            
            if ([nameOrURLPathOrFileURL isKindOfClass:NSURL.class])
            {
                if ([nameOrURLPathOrFileURL isFileURL])
                {
                    url = nameOrURLPathOrFileURL;
                }
                else
                {
                    url = [NSURL fileURLWithPath:[nameOrURLPathOrFileURL path]];
                }
            }
            else
            {
                url = [NSURL URLWithString:nameOrURLPathOrFileURL];
                
                if (!url)
                {
                    url = [NSURL fileURLWithPath:[self mjz_pathForRealmWithName:_name]];
                }
                else
                {
                    if (!url.isFileURL)
                    {
                        url = [NSURL fileURLWithPath:nameOrURLPathOrFileURL];
                    }
                }
            }
            
            _configuration.fileURL = url;
        }
        
        _configuration.encryptionKey = [self mjz_realmEncryptionKeyForName:_encryptionKeyName];
        
        _isValidated = NO;
    }
    return self;
}

- (void)setRealmClasses:(NSArray<Class> *)realmClasses
{
    @synchronized (self)
    {
        if (_isValidated)
        {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"This method must be called before getting any instance via the method -realmInstance."
                                         userInfo:nil];
        }
        _configuration.objectClasses = realmClasses;
    }
}

- (void)setRealmSchemaVersion:(uint64_t)schemaVersion
{
    @synchronized (self)
    {
        if (_isValidated)
        {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"This method must be called before getting any instance via the method -realmInstance."
                                         userInfo:nil];
        }
        
        _configuration.schemaVersion = schemaVersion;
    }
}

- (void)setMinimumValidMigrationSchemaVersion:(uint64_t)minimumValidMigrationSchemaVersion
{
    @synchronized (self)
    {
        if (_isValidated)
        {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"This method must be called before getting any instance via the method -realmInstance."
                                         userInfo:nil];
        }
        
        _minimumValidMigrationSchemaVersion = minimumValidMigrationSchemaVersion;
    }
}

- (void)setRealmMigrationBlock:(RLMMigrationBlock)migrationBlock
{
    @synchronized (self)
    {
        if (_isValidated)
        {
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"This method must be called before getting any instance via the method -realmInstance."
                                         userInfo:nil];
        }
        
        _configuration.migrationBlock = migrationBlock;
    }
}

- (RLMRealm*)realmInstance
{
    @synchronized (self)
    {
        if (_isValidated == NO)
        {
            [self mjz_validateRealm];
            _isValidated = YES;
        }
    }
    
    RLMRealm *realm = nil;
    NSError *realmCreationError = nil;
    
    @synchronized (self)
    {
        realm = [RLMRealm realmWithConfiguration:_configuration error:&realmCreationError];
    }
    
    if (realmCreationError)
    {
        NSLog(@"[WARNING] Realm database couldn't be created: %@", realmCreationError.description);
    }
    
    return realm;
}

- (NSString*)realmFilePath
{
    return [self mjz_pathForRealmWithName:_name];
}

#pragma mark Private Methods

- (void)mjz_validateRealm
{
    NSString *realmPath = [_configuration.fileURL path];
    NSLog(@"RealmPath: %@", realmPath);
    
    if (_minimumValidMigrationSchemaVersion != RLMNotVersioned)
    {
        NSError *schemaError = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:realmPath])
        {
            uint64_t version = [RLMRealm schemaVersionAtURL:[NSURL fileURLWithPath:realmPath]
                                              encryptionKey:[self mjz_realmEncryptionKeyForName:_encryptionKeyName]
                                                      error:&schemaError];
            
            if (version == RLMNotVersioned || version < _minimumValidMigrationSchemaVersion)
            {
                [[NSFileManager defaultManager] removeItemAtPath:realmPath error:nil];
            }
        }
    }
}

- (NSData*)mjz_realmEncryptionKeyForName:(NSString*)name
{
    if (name)
    {
        MJSecureKey *secureKey = [MJSecureKey secureKeyWithIdentifier:name length:64];
        return secureKey.key;
    }
    
    return nil;
}

- (NSString*)mjz_pathForRealmWithName:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *realmPath = [[paths firstObject] stringByAppendingPathComponent:name];
    return realmPath;
}

@end
