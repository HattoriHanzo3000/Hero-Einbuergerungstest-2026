#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.gizatech.Leben-in-Deutschland";

/// The "AccentColor" asset catalog color resource.
static NSString * const ACColorNameAccentColor AC_SWIFT_PRIVATE = @"AccentColor";

/// The "AppGreen" asset catalog color resource.
static NSString * const ACColorNameAppGreen AC_SWIFT_PRIVATE = @"AppGreen";

/// The "AppOrange" asset catalog color resource.
static NSString * const ACColorNameAppOrange AC_SWIFT_PRIVATE = @"AppOrange";

/// The "AppPink" asset catalog color resource.
static NSString * const ACColorNameAppPink AC_SWIFT_PRIVATE = @"AppPink";

/// The "AppRed" asset catalog color resource.
static NSString * const ACColorNameAppRed AC_SWIFT_PRIVATE = @"AppRed";

/// The "AppYellow" asset catalog color resource.
static NSString * const ACColorNameAppYellow AC_SWIFT_PRIVATE = @"AppYellow";

/// The "Block" asset catalog color resource.
static NSString * const ACColorNameBlock AC_SWIFT_PRIVATE = @"Block";

/// The "CategoryButton" asset catalog color resource.
static NSString * const ACColorNameCategoryButton AC_SWIFT_PRIVATE = @"CategoryButton";

/// The "CategoryText" asset catalog color resource.
static NSString * const ACColorNameCategoryText AC_SWIFT_PRIVATE = @"CategoryText";

/// The "Correct" asset catalog color resource.
static NSString * const ACColorNameCorrect AC_SWIFT_PRIVATE = @"Correct";

/// The "CorrectCircle" asset catalog color resource.
static NSString * const ACColorNameCorrectCircle AC_SWIFT_PRIVATE = @"CorrectCircle";

/// The "Fill" asset catalog color resource.
static NSString * const ACColorNameFill AC_SWIFT_PRIVATE = @"Fill";

/// The "Selected" asset catalog color resource.
static NSString * const ACColorNameSelected AC_SWIFT_PRIVATE = @"Selected";

/// The "SelectedCircle" asset catalog color resource.
static NSString * const ACColorNameSelectedCircle AC_SWIFT_PRIVATE = @"SelectedCircle";

/// The "Unselected" asset catalog color resource.
static NSString * const ACColorNameUnselected AC_SWIFT_PRIVATE = @"Unselected";

/// The "Wrong" asset catalog color resource.
static NSString * const ACColorNameWrong AC_SWIFT_PRIVATE = @"Wrong";

/// The "WrongCircle" asset catalog color resource.
static NSString * const ACColorNameWrongCircle AC_SWIFT_PRIVATE = @"WrongCircle";

/// The "Logo" asset catalog image resource.
static NSString * const ACImageNameLogo AC_SWIFT_PRIVATE = @"Logo";

/// The "MainChick" asset catalog image resource.
static NSString * const ACImageNameMainChick AC_SWIFT_PRIVATE = @"MainChick";

#undef AC_SWIFT_PRIVATE
