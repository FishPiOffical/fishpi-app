//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<images_picker/ImagesPickerPlugin.h>)
#import <images_picker/ImagesPickerPlugin.h>
#else
@import images_picker;
#endif

#if __has_include(<scan/ScanPlugin.h>)
#import <scan/ScanPlugin.h>
#else
@import scan;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [ImagesPickerPlugin registerWithRegistrar:[registry registrarForPlugin:@"ImagesPickerPlugin"]];
  [ScanPlugin registerWithRegistrar:[registry registrarForPlugin:@"ScanPlugin"]];
}

@end
