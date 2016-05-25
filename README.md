# MJCocoaCore

## How to 

To install the MJCocoaCore library, just paste the following line in your podfile:
```
pod 'MJCocoaCore', :git => 'https://github.com/mobilejazz/MJCocoaCore.git', :tag => '0.1.6'
```

We also have some subpods that can be installed like this:
```ruby
pod 'MJCocoaCore/NSDataAES'
pod 'MJCocoaCore/StringAddition'
pod 'MJCocoaCore/MJCore'
pod 'MJCocoaCore/MJCoreRealm'
pod 'MJCocoaCore/MJAppLinkRecognizer'
pod 'MJCocoaCore/MJSecureKey'
```

## Dependencies

MJCocoaCore/Realm rely on Realm, but the dependency is automatically managed bu CocoaPods.

## Included classes
### Categories
#### NSDataAES
- NSData+AES
- NSData+AESKey 
- NSData+AESValue
- NSMutableData+AES

#### StringAddition

- NSString+Additions

### Core
- MJDataProviderDirector
- MJDEntity
- MJDEntityMapper
- MJInteractor

### Realm
- MJModelObject
- MJDRealmObject
- MJDRealmMapper

### Other
#### MJAppLinkRecognizer
- MJAppLinkRecognizer

#### MJSecureKey

- MJSecureKey

