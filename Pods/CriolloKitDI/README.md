DI
[![Build Status](https://travis-ci.org/CriolloKit/DI.png?branch=master)](https://travis-ci.org/CriolloKit/DI)
==

Inspired by 

* AppleGuice
* Objection

Features

*

Road Map

* Injection Configuration Modules
* Bind class to protocol 

`
[module bindClass:[UserClass class] toProtocol:@protocol(UserService)];
`

* Bind class to class

`
[module bindClass:[MyNSString class] toClass:[NSString class]];
`

* Bind factory block to protocol

`
[module bindBlock:^{
  return [[UserClass alloc] initWithParam:@1];
} toProtocol:@protocol(UserService)];
`

* Property Injection

`
@property (nonatomic, strong) id<UserService> ioc_userService;
`

* Factory methods

`
Service *s = [module instanceForProtocol:@protocol(Service)];
`

* Different instantiation modes (Normal/Singltone)

`
[module bindClass:[UserClass class] toProtocol:@protocol(UserService) mode:DIInstantiationModeSingltone];
`
