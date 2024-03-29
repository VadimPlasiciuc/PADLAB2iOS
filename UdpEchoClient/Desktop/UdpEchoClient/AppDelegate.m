#import "AppDelegate.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "GCDAsyncUdpSocket.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
NSMutableArray *addressArray;
#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]


@implementation AppDelegate

@synthesize window = _window;
@synthesize addrField;
@synthesize portField;
@synthesize messageField;
@synthesize sendButton;
@synthesize logView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Setup our logging framework.
	
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	// Setup our socket.
	// The socket will invoke our delegate methods using the usual delegate paradigm.
	// However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
	// 
	// Now we can configure the delegate dispatch queues however we want.
	// We could simply use the main dispatc queue, so the delegate methods are invoked on the main thread.
	// Or we could use a dedicated dispatch queue, which could be helpful if we were doing a lot of processing.
	// 
	// The best approach for your application will depend upon convenience, requirements and performance.
	// 
	// For this simple example, we're just going to use the main thread.
    addressArray = [[NSMutableArray alloc]init];
	udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [udpSocket setIPv4Enabled:YES];
   	NSError *error = nil;
	
	if (![udpSocket bindToPort:0 error:&error])
	{
		DDLogError(@"Error binding: %@", error);
		return;
	}
	if (![udpSocket beginReceiving:&error])
	{
		DDLogError(@"Error receiving: %@", error);
		return;
	}
	if(![udpSocket joinMulticastGroup:@"239.255.255.250" error:&error])
    {
        DDLogError(@"Error receiving: %@", error);
        return;
    }
	DDLogVerbose(@"Ready");
}

- (void)scrollToBottom
{
	NSScrollView *scrollView = [logView enclosingScrollView];
	NSPoint newScrollOrigin;
	
	if ([[scrollView documentView] isFlipped])
		newScrollOrigin = NSMakePoint(0.0F, NSMaxY([[scrollView documentView] frame]));
	else
		newScrollOrigin = NSMakePoint(0.0F, 0.0F);
	
	[[scrollView documentView] scrollPoint:newScrollOrigin];
}

- (void)logError:(NSString *)msg
{
	NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
	[attributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
	
	[[logView textStorage] appendAttributedString:as];
	[self scrollToBottom];
}

- (void)logInfo:(NSString *)msg
{
	NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
	[attributes setObject:[NSColor purpleColor] forKey:NSForegroundColorAttributeName];
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
	
	[[logView textStorage] appendAttributedString:as];
	[self scrollToBottom];
}

- (void)logMessage:(NSString *)msg
{
	NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
	[attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
	
	[[logView textStorage] appendAttributedString:as];
	[self scrollToBottom];
}

- (IBAction)send:(id)sender
{
    NSString *host = addrField.stringValue;
	if ([host length] == 0)
	{
		[self logError:@"Address required"];
		return;
	}
	
	int port = [portField intValue];
	if (port <= 0 || port > 65535)
	{
		[self logError:@"Valid port required"];
		return;
	}

	NSString *msg = [messageField stringValue];
	if ([msg length] == 0)
	{
		[self logError:@"Message required"];
		return;
	}
	
	NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    if([msg  isEqual: @"Maven"]){
	[udpSocket sendData:data toHost:host port:14222 withTimeout:-1 tag:tag];
    [udpSocket sendData:data toHost:host port:14333 withTimeout:-1 tag:tag];
    [udpSocket sendData:data toHost:host port:14444 withTimeout:-1 tag:tag];
    NSLog(@"Host %@",host);
	[self logMessage:FORMAT(@"SENT (%i): %@", (int)tag, msg)];
    }
    if([msg  isEqual: @"Data"]){
        //[udpSocket sendData:data toHost:host port:14444 withTimeout:-1 tag:tag];
        NSLog(@"Host %@",host);
        [udpSocket sendData:data toAddress:[addressArray firstObject] withTimeout:-1 tag:tag];
        [self logMessage:FORMAT(@"SENT (%i): %@", (int)tag, msg)];
    }
	
	//tag++;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
                                               fromAddress:(NSData *)address
                                         withFilterContext:(id)filterContext
{
    NSString *xmlMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSString *msg = [NSString alloc];
//    NSRange replaceRange = [xmlMessage rangeOfString:@"<Student><Message>"];
//    if (replaceRange.location != NSNotFound){
//        msg = [xmlMessage stringByReplacingCharactersInRange:replaceRange withString:@""];
//    }
//        replaceRange = [msg rangeOfString:@"</Message></Student>"];
//        if (replaceRange.location != NSNotFound)
//        {
//        NSString* result = [msg stringByReplacingCharactersInRange:replaceRange withString:@""];
//            msg = result;
//            
//    }
        if([xmlMessage isEqual:@"MavenFour-3"])
        {
            [addressArray addObject:address];
        }
        if (xmlMessage)
        {
          if(![xmlMessage hasPrefix:@"G"])
          {
		[self logMessage:FORMAT(@"RECV: %@", xmlMessage)];
          }
        }
        else
        {
		NSString *host = nil;
		uint16_t port = 0;
		[GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
     
		[self logInfo:FORMAT(@"RECV: Unknown message from: %@:%hu", host, port)];
        }

            NSLog(@"Adress %@",address);
}

@end
