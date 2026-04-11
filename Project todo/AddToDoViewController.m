//
//  AddToDoViewController.m
//  Project todo
//
//  Created by Ahmed Salah on 07/04/2026.
//

#import "AddToDoViewController.h"
#import "TodoManager.h"
@interface AddToDoViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *statusSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegment;
@property (weak, nonatomic) IBOutlet UILabel *screenTitle;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *reminderDate;

@end

@implementation AddToDoViewController
- (IBAction)addBtn:(id)sender {

    NSString *title = self.titleTextField.text;
    NSString *desc = self.descTextView.text;
    NSDate *reminder =self.reminderDate.date;
    BOOL isReminder = [reminder timeIntervalSinceNow] > 0;
    if([desc
        isEqualToString:@"Enter description..."]){
        desc=@"";
    }
    if (title.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Title"
                    message:@"Please enter a task title."
                    preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                style:UIAlertActionStyleDefault
                handler:nil]];

        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    NSInteger status = self.statusSegment.selectedSegmentIndex;
    NSInteger priority = self.prioritySegment.selectedSegmentIndex+1;

    if (self.item == nil) {

        TodoItem *newItem = [[TodoItem alloc] initWithTitle:title
                                           todoDescription:desc
                                                   priority:priority
                                                   reminderDate:reminder
                                                 isReminder:isReminder
                                                    status:status];

        [[TodoManager sharedManager] addTodo:newItem];
        if (newItem.isReminder) {
            [self scheduleNotificationForItem:newItem];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:@"TodoUpdated" object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    else {


        BOOL isSame =
        [self.item.title isEqualToString:title] &&
        [self.item.todoDescription isEqualToString:desc] &&
        self.item.priority == priority &&
        self.item.status == status
        &&[self.item.reminderDate isEqualToDate:reminder]
        ;

        if (isSame) {
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Update Task"
                        message:@"Are you sure you want to update this task?"
                    preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                    style:UIAlertActionStyleCancel
                    handler:nil]];

        [alert addAction:[UIAlertAction actionWithTitle:@"Update"
                    style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction * _Nonnull action) {

            self.item.title = title;
            self.item.todoDescription = desc;
            self.item.priority = priority;
            self.item.status = status;
            self.item.reminderDate=reminder;
            self.item.isReminder=isReminder;

            [[TodoManager sharedManager] updateTodo:self.item];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"TodoUpdated" object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];

        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        if(_item ==nil){
            _screenTitle.text=@"New Task";
        }else{
            _screenTitle.text=@"Update Task";
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate=self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            NSLog(@"Permission granted");
        }
    }];


    [_datePicker setEnabled:NO];
    [self styleTextField:self.titleTextField];
    [self styleTextView:self.descTextView];
    
    self.descTextView.delegate = self;

    if (self.item == nil) {
        _screenTitle.text=@"New Task";

        self.descTextView.text = @"Enter description...";
                self.descTextView.textColor = [UIColor lightGrayColor];

        [self.statusSegment setSelectedSegmentIndex:0]; 
        [self.prioritySegment setSelectedSegmentIndex:0];
        [self.actionButton setTitle:@"Add Task" forState:UIControlStateNormal];
        [self.actionButton setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal];
    } else {
        _screenTitle.text=@"Update Task";

        [_datePicker setDate:_item.date];
        self.titleTextField.text = self.item.title;
        self.descTextView.text = self.item.todoDescription;

        self.statusSegment.selectedSegmentIndex = self.item.status;
        self.prioritySegment.selectedSegmentIndex = self.item.priority - 1;
        [self.actionButton setTitle:@"Update Task" forState:UIControlStateNormal];
            [self.actionButton setImage:[UIImage systemImageNamed:@"pencil"] forState:UIControlStateNormal];
        [self handleStatusRules];
    }
    if (self.item == nil) {
        [self.statusSegment setEnabled:NO forSegmentAtIndex:2];
    }
    
    [self styleSegment:self.statusSegment];
    [self styleSegment:self.prioritySegment];
}
- (IBAction)statusChanged:(UISegmentedControl *)sender {
    [self handleStatusRules];
}
- (void)handleStatusRules {
    NSInteger status = self.statusSegment.selectedSegmentIndex;

    for (int i = 0; i < self.statusSegment.numberOfSegments; i++) {
        [self.statusSegment setEnabled:YES forSegmentAtIndex:i];
    }
    if(status==0){
        [self.statusSegment setEnabled:NO forSegmentAtIndex:2];

    }
    if (status == 1) {
        [self.statusSegment setEnabled:NO forSegmentAtIndex:0];

    } else if (status == 2) {
        [self.statusSegment setEnabled:NO forSegmentAtIndex:0];
        [self.statusSegment setEnabled:NO forSegmentAtIndex:1];

        NSInteger selectedPriorityIndex = self.item.priority - 1;

        for (int i = 0; i < self.prioritySegment.numberOfSegments; i++) {
            [self.prioritySegment setEnabled:NO forSegmentAtIndex:i];
        }

        [self.prioritySegment setEnabled:YES forSegmentAtIndex:selectedPriorityIndex];

        [self.prioritySegment setSelectedSegmentIndex:selectedPriorityIndex];

        self.actionButton.enabled = NO;
        self.actionButton.hidden=YES;
        self.titleTextField.enabled = NO;
        self.descTextView.editable = NO;
    }
}
- (void)styleTextField:(UITextField *)textField {
    
    textField.backgroundColor = [UIColor whiteColor];

    textField.layer.cornerRadius = 12;
    textField.layer.masksToBounds = NO;

    textField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    textField.layer.borderWidth = 1.0;

    textField.layer.shadowColor = [UIColor blackColor].CGColor;
    textField.layer.shadowOpacity = 0.1;
    textField.layer.shadowOffset = CGSizeMake(0, 2);
    textField.layer.shadowRadius = 4;

    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;

    [textField addTarget:self action:@selector(editingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [textField addTarget:self action:@selector(editingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
    [self addIcon:@"textformat" toTextField:self.titleTextField];
}
- (void)editingDidBegin:(UITextField *)textField {
    textField.layer.borderColor = [UIColor systemBlueColor].CGColor;
}

- (void)editingDidEnd:(UITextField *)textField {
    textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
}
- (void)addIcon:(NSString *)systemName toTextField:(UITextField *)textField {

    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:systemName]];
    icon.frame = CGRectMake(0, 0, 20, 20);
    icon.contentMode = UIViewContentModeScaleAspectFit;

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];

    icon.center = CGPointMake(container.frame.size.width / 2,
                              container.frame.size.height / 2);

    [container addSubview:icon];

    textField.leftView = container;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)styleSegment:(UISegmentedControl *)segment {

    segment.selectedSegmentTintColor = [UIColor systemBlueColor];

    NSDictionary *normalAttributes = @{
        NSForegroundColorAttributeName: [UIColor systemGrayColor],
        NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightMedium]
    };

    NSDictionary *selectedAttributes = @{
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]
    };

    [segment setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    [segment setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];

    segment.backgroundColor = [UIColor systemGray5Color];

    segment.layer.cornerRadius = 10;
    segment.layer.masksToBounds = YES;
}

- (void)styleTextView:(UITextView *)textView {
    
    textView.backgroundColor = [UIColor whiteColor];

    textView.layer.cornerRadius = 12;
    textView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    textView.layer.borderWidth = 1.0;

    textView.layer.shadowColor = [UIColor blackColor].CGColor;
    textView.layer.shadowOpacity = 0.1;
    textView.layer.shadowOffset = CGSizeMake(0, 2);
    textView.layer.shadowRadius = 4;

    textView.font = [UIFont systemFontOfSize:16];
    textView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Enter description..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.text = @"Enter description...";
        textView.textColor = [UIColor lightGrayColor];
    }
}

- (void)scheduleNotificationForItem:(TodoItem *)item {

    if (!item.isReminder || !item.reminderDate) return;

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    [center removePendingNotificationRequestsWithIdentifiers:@[item.uuid]];

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = item.title ?: @"Reminder";
    content.body = item.todoDescription.length > 0 ? item.todoDescription : @"Don't forget your task!";
    content.sound = [UNNotificationSound defaultSound];

    NSDateComponents *components = [[NSCalendar currentCalendar]
        components:(NSCalendarUnitYear |
                    NSCalendarUnitMonth |
                    NSCalendarUnitDay |
                    NSCalendarUnitHour |
                    NSCalendarUnitMinute)
        fromDate:item.reminderDate];

    UNCalendarNotificationTrigger *trigger =
    [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];

    UNNotificationRequest *request =
    [UNNotificationRequest requestWithIdentifier:item.uuid
                                         content:content
                                         trigger:trigger];

    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Reminder error: %@", error);
        }
    }];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {

    completionHandler(UNNotificationPresentationOptionBanner |
                      UNNotificationPresentationOptionSound);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
