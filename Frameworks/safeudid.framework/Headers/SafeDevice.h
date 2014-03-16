
typedef void  (^ActiveBlock)(int );
@interface SafeDevice : NSObject
@property(atomic,strong)NSString *deviceId;
@property(atomic,strong)NSDictionary *deviceInfo;
-(NSString*)udid;
-(NSString *)serial;
+(SafeDevice *)build;
@end

