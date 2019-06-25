#import "TazzSocket.h"
#import <tazz_socket/tazz_socket-Swift.h>

@implementation TazzSocket
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTazzSocket registerWithRegistrar:registrar];
}
@end
