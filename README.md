![MJCocoaCore](https://raw.githubusercontent.com/mobilejazz/metadata/master/images/banners/mobile-jazz-mjcocoacore.png)

# ![Mobile Jazz Badge](https://raw.githubusercontent.com/mobilejazz/metadata/master/images/icons/mj-40x40.png) MJCocoaCore

Utilities not dependent on UIKit, so they can be used in iOS, tvOS and macOS projects


## How to 

To install the MJ Cocoa Core library, just paste the following line in your podfile:
```
pod 'mj-cocoa-core', :git => 'https://bitbucket.org/mobilejazz/mj-cocoa-core.git', :tag => '1.0.0'
```

We also have some subpods that can be installed like this:
```ruby
pod 'mj-cocoa-core/NSDataAES'
pod 'mj-cocoa-core/StringAddition'
pod 'mj-cocoa-core/MJCore'
pod 'mj-cocoa-core/MJCoreRealm'
pod 'mj-cocoa-core/MJAppLinkRecognizer'
pod 'mj-cocoa-core/MJSecureKey'
```

## Dependencies

mj-cocoa-core/Realm rely on Realm, but the dependency is automatically managed by CocoaPods.

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

