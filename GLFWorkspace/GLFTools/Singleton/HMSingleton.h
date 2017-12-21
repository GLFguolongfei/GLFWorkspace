

// .h文件
#define HMSingletonH(name) + (instancetype)shared##name;

// .m文件
#if __has_feature(objc_arc) // ARC

    #define HMSingletonM(name) \
    \
    static id _instace; \
    \
    + (id)allocWithZone:(struct _NSZone *)zone { \
        static dispatch_once_t onceToken; \
        dispatch_once(&onceToken, ^{ \
            _instace = [super allocWithZone:zone]; \
        }); \
        return _instace; \
    } \
    \
    - (id)copyWithZone:(NSZone *)zone { \
        return _instace; \
    } \
    \
    + (instancetype)shared##name { \
        return [[self alloc] init]; \
    } 

#else // MRC

    #define HMSingletonM(name) \
    \
    static id _instace; \
    \
    + (id)allocWithZone:(struct _NSZone *)zone { \
        static dispatch_once_t onceToken; \
        dispatch_once(&onceToken, ^{ \
            _instace = [super allocWithZone:zone]; \
        }); \
        return _instace; \
    } \
    \
    - (id)copyWithZone:(NSZone *)zone { \
        return _instace; \
    } \
    \
    - (oneway void)release { } \
    - (id)retain { return self; } \
    - (NSUInteger)retainCount { return MAXFLOAT;} \
    - (id)autorelease { return self;} \
    \
    + (instancetype)shared##name { \
        return [[self alloc] init]; \
    }

#endif


// 加一个“\”: 表示后面一行的代码和前一行属于同行
// 加一个“##”: 表示后面的代码要拼接前面的代码

