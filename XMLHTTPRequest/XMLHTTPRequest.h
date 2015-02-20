#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>


NS_ENUM(NSUInteger , ReadyState) {
    UNSENT=0,	// open()has not been called yet.
    OPENED,	    // send()has not been called yet.
    HEADERS,    // RECEIVED	send() has been called, and headers and status are available.
    LOADING,    // Downloading; responseText holds partial data.
    DONE	    // The operation is complete.
};

@protocol XMLHttpRequest <JSExport>
@property (nonatomic) NSString *responseText;
@property (nonatomic) JSValue *onreadystatechange;
@property (nonatomic) NSNumber *readyState;
@property (nonatomic) JSValue *onload;
@property (nonatomic) JSValue *onerror;
@property (nonatomic) NSNumber *status;


-(void)open:(NSString *)httpMethod :(NSString *)url :(bool)async;
-(void)send:(id)data;
-(void)setRequestHeader: (NSString *)name :(NSString *)value;
-(NSString *)getAllResponseHeaders;
-(NSString *)getReponseHeader:(NSString *)name;
@end



@interface XMLHttpRequest : NSObject <XMLHttpRequest>

- (instancetype)initWithURLSession: (NSURLSession *)urlSession;

- (void)extend:(id)jsContext;
@end
