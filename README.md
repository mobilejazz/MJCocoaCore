**WARNING: This project has been moved to [bitbucket](https://bitbucket.org/mobilejazz/mj-cocoa-core). Do not use this version as it is going to be deprecated in the following weeks.**

![MJCocoaCore](https://raw.githubusercontent.com/mobilejazz/metadata/master/images/banners/mobile-jazz-mjcocoacore.png)

# ![Mobile Jazz Badge](https://raw.githubusercontent.com/mobilejazz/metadata/master/images/icons/mj-40x40.png) MJCocoaCore

Utilities not dependent on UIKit, so they can be used in iOS, tvOS and macOS projects


## How to install


To install the MJ Cocoa Core library using [Cocoapods](https://cocoapods.org/), just paste the following line in your podfile:
```ruby
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

mj-cocoa-core/MJCoreRealm rely on Realm, but the dependency is automatically managed by CocoaPods.

## Included classes
### Categories

#### StringAddition: This category adds some utilities for String manipulation.

- files `NSString+Additions.h & .m`. 

- `add_words`: this addition splits a String and creates an array with all the "words" in that string

```objectivec

NSString *testString = @"This is really awesome I mean awesome ++";
NSArray <NSString *> *words = [testString add_words];

// words contains @[@"This",  @"is", @"really",  @"awesome",  @"I",  @"mean",  @"awesome",  @"++"]

```

- `add_firstWord`: this addition returns the first word from a String

```objectivec
NSString *testString = @"This is really awesome I mean awesome ++";
NSString *sut = [testString add_firstWord]; // sut contains @"This"
```

- `add_lastWord`: this addition returns the last word from a String

- `add_stringByDeletingFirstWord`: returns all but the first word in a String

- `add_randomString`: returns a random String, at least 10 characters long

- `add_randomStringWithLength`: returns a random String, with the given length

- `add_uniqueString`: returns a string we can use as identificator

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

## Running the sample

To run the sample:

- clone this repo
- `cd` into `Sample Project`
- run `pod install` from command line
- use the WorkSpace & enjoy
- check the Unit tests 