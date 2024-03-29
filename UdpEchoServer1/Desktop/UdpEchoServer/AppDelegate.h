#import <Cocoa/Cocoa.h>
#import "GCDAsyncUdpSocket.h"


@interface AppDelegate : NSObject <NSApplicationDelegate, GCDAsyncUdpSocketDelegate>
{
	GCDAsyncUdpSocket *udpSocket;
	BOOL isRunning;
    long tag;
}

@property (unsafe_unretained) IBOutlet NSWindow *window;
@property  IBOutlet NSTextField *portField;
@property  IBOutlet NSButton *startStopButton;
@property  IBOutlet NSTextView *logView;

- (IBAction)startStopButtonPressed:(id)sender;

@end
