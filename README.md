![MJCocoaCore](https://raw.githubusercontent.com/mobilejazz/metadata/master/images/banners/mobile-jazz-mjcocoacore.png)

# ![Mobile Jazz Badge](https://raw.githubusercontent.com/mobilejazz/metadata/master/images/icons/mj-40x40.png) MJCocoaCore

Utilities not dependent on UIKit, so they can be used in iOS, tvOS and macOS projects


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

