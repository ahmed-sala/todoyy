//
//  AddToDoViewController.h
//  Project todo
//
//  Created by Ahmed Salah on 07/04/2026.
//

#import <UIKit/UIKit.h>
#import "TodoItem.h"
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddToDoViewController : UIViewController <UITextViewDelegate,UNUserNotificationCenterDelegate>
@property (nullable, nonatomic, strong) TodoItem *item;
@end

NS_ASSUME_NONNULL_END
