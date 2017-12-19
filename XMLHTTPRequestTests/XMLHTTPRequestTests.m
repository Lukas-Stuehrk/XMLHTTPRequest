#import <Kiwi/Kiwi.h>

#define HC_SHORTHAND

#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND

#import <OCMockito/OCMockito.h>
#import "XMLHTTPRequest.h"


SPEC_BEGIN(XMLHttpRequestTests)

    describe(@"the XMLHTTPRequest", ^{
        __block JSContext *jsContext;

        beforeEach(^{
            jsContext = [JSContext new];
            XMLHttpRequest *xmlHttpRequest = [XMLHttpRequest new];
            [xmlHttpRequest extend:jsContext];
        });

        it(@"should be a constructor", ^{
            JSValue *object = [jsContext evaluateScript:@"new XMLHttpRequest()"];
            [[[jsContext exception] should] beNil];
            [[object should] beNonNil];
        });

        it(@"should provide all the constants", ^{
            [[[jsContext evaluateScript:@"XMLHttpRequest.UNSENT"] should] equal:[JSValue valueWithInt32:0
                                                                                              inContext:jsContext]];
            [[[jsContext evaluateScript:@"XMLHttpRequest.OPENED"] should] equal:[JSValue valueWithInt32:1
                                                                                              inContext:jsContext]];
            [[[jsContext evaluateScript:@"XMLHttpRequest.HEADERS"] should] equal:[JSValue valueWithInt32:2
                                                                                               inContext:jsContext]];
            [[[jsContext evaluateScript:@"XMLHttpRequest.LOADING"] should] equal:[JSValue valueWithInt32:3
                                                                                               inContext:jsContext]];
            [[[jsContext evaluateScript:@"XMLHttpRequest.DONE"] should] equal:[JSValue valueWithInt32:4
                                                                                            inContext:jsContext]];

        });
    });

    describe(@"the open method", ^{
        __block JSContext *jsContext;

        beforeEach(^{
            jsContext = [JSContext new];
            XMLHttpRequest *xmlHttpRequest = [XMLHttpRequest new];
            [xmlHttpRequest extend:jsContext];
            [jsContext evaluateScript:@"var request = new XMLHttpRequest();"];
        });

        it(@"should exist", ^{
            [jsContext evaluateScript:@"request.open('POST', 'http://google.de');"];
            [[[jsContext exception] should] beNil];
        });

        it(@"should raise an error if called with not enough arguments", ^{
            [jsContext evaluateScript:@"request.open()"];
            [[[jsContext exception] should] beNonNil];
            [jsContext evaluateScript:@"request.open('POST')"];
            [[[jsContext exception] should] beNonNil];
        });

    });

    describe(@"the request", ^{
        __block JSContext *jsContext;
        __block NSURLSession *urlSession;
        __block XMLHttpRequest *request;

        beforeEach(^{
            urlSession = mock([NSURLSession class]);
            jsContext = [JSContext new];
            XMLHttpRequest *xmlHttpRequest = [[XMLHttpRequest alloc] initWithURLSession:urlSession];
            [xmlHttpRequest extend:jsContext];
            [jsContext evaluateScript:@"var request = new XMLHttpRequest();"];
            request = [jsContext[@"request"] toObject];
        });

        it(@"should call the correct URL", ^{
            MKTArgumentCaptor *argument = [MKTArgumentCaptor new];

            [jsContext evaluateScript:@""
                    "request.open('GET', 'http://example.com');"
                    "request.send();"];

            [verify(urlSession) dataTaskWithRequest:[argument capture]
                                  completionHandler:anything()];
            NSMutableURLRequest *urlRequest = argument.value;
            [[[urlRequest URL] should] equal:[NSURL URLWithString:@"http://example.com"]];
        });

        it(@"should set the correct headers", ^{
            MKTArgumentCaptor *argument = [MKTArgumentCaptor new];

            [jsContext evaluateScript:@""
                    "request.open('GET', 'http://example.com');"
                    "request.setRequestHeader('Accept', 'text/html');"
                    "request.setRequestHeader('X-Foo', 'bar');"
                    "request.send();"];

            [verify(urlSession) dataTaskWithRequest:[argument capture]
                                  completionHandler:anything()];
            NSMutableURLRequest *urlRequest = argument.value;
            [[[urlRequest allHTTPHeaderFields] should] equal:@{@"Accept" : @"text/html", @"X-Foo" : @"bar"}];
        });

        it(@"should set the correct readystate", ^{
            MKTArgumentCaptor *argument = [MKTArgumentCaptor new];
            [[request.readyState should] equal:@(XMLHttpRequestUNSENT)];
            [jsContext evaluateScript:@"request.open('GET', 'http://example.com');"];
            [[request.readyState should] equal:@(XMLHttpRequestOPENED)];
            [jsContext evaluateScript:@"request.send()"];
            [verify(urlSession) dataTaskWithRequest:anything()
                                  completionHandler:[argument capture]];
            NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"http://example.com"]
                                                                  statusCode:200
                                                                 HTTPVersion:@"1.1"
                                                                headerFields:@{}];
            void (^completionBlock)(NSData *, NSURLResponse *, NSError *) = [argument value];
            completionBlock([NSData new], response, nil);
            [[request.readyState should] equal:@(XMLHttpRequestDONE)];
        });

        it(@"should set the correct response text", ^{
            MKTArgumentCaptor *argument = [MKTArgumentCaptor new];
            [jsContext evaluateScript:@"request.open('GET', 'http://example.com');"];
            [jsContext evaluateScript:@"request.send()"];
            [verify(urlSession) dataTaskWithRequest:anything()
                                  completionHandler:[argument capture]];
            NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"http://example.com"]
                                                                  statusCode:200
                                                                 HTTPVersion:@"1.1"
                                                                headerFields:@{}];
            NSData *responseText = [@"foobar" dataUsingEncoding:NSUTF8StringEncoding];
            void (^completionBlock)(NSData *, NSURLResponse *, NSError *) = [argument value];
            completionBlock(responseText, response, nil);
            [[request.responseText should] equal:@"foobar"];
        });

        it(@"should return all response headers", ^{
            MKTArgumentCaptor *argument = [MKTArgumentCaptor new];
            [jsContext evaluateScript:@"request.open('GET', 'http://example.com');"];
            [jsContext evaluateScript:@"request.send()"];
            [verify(urlSession) dataTaskWithRequest:anything()
                                  completionHandler:[argument capture]];
            NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"http://example.com"]
                                                                  statusCode:200
                                                                 HTTPVersion:@"1.1"
                                                                headerFields:@{@"Content-Type" : @"text/html", @"X-Foo" : @"Bar"}];
            NSData *responseText = [@"foobar" dataUsingEncoding:NSUTF8StringEncoding];
            void (^completionBlock)(NSData *, NSURLResponse *, NSError *) = [argument value];
            completionBlock(responseText, response, nil);
            // TODO it's a little bit fragile
            [[request.getAllResponseHeaders should] equal:@"X-Foo: Bar\r\nContent-Type: text/html\r\n"];
        });

        it(@"should return the correct response headers", ^{
            MKTArgumentCaptor *argument = [MKTArgumentCaptor new];
            [jsContext evaluateScript:@"request.open('GET', 'http://example.com');"];
            [jsContext evaluateScript:@"request.send()"];
            [verify(urlSession) dataTaskWithRequest:anything()
                                  completionHandler:[argument capture]];
            NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"http://example.com"]
                                                                  statusCode:200
                                                                 HTTPVersion:@"1.1"
                                                                headerFields:@{@"Content-Type" : @"text/html", @"X-Foo" : @"Bar"}];
            NSData *responseText = [@"foobar" dataUsingEncoding:NSUTF8StringEncoding];
            void (^completionBlock)(NSData *, NSURLResponse *, NSError *) = [argument value];
            completionBlock(responseText, response, nil);
        
            [[[[jsContext evaluateScript:@"request.getResponseHeader('Content-Type');"] toString] should] equal:@"text/html"];
        });

        it(@"should set the HTTP status code", ^{
            MKTArgumentCaptor *argument = [MKTArgumentCaptor new];
            [jsContext evaluateScript:@"request.open('GET', 'http://example.com');"];
            [jsContext evaluateScript:@"request.send()"];
            [verify(urlSession) dataTaskWithRequest:anything()
                                  completionHandler:[argument capture]];
            NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"http://example.com"]
                                                                  statusCode:200
                                                                 HTTPVersion:@"1.1"
                                                                headerFields:@{}];
            NSData *responseText = [@"foobar" dataUsingEncoding:NSUTF8StringEncoding];
            void (^completionBlock)(NSData *, NSURLResponse *, NSError *) = [argument value];
            completionBlock(responseText, response, nil);
            [[request.status should] equal:@(200)];
        });
    });

SPEC_END
