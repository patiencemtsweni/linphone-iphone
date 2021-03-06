//
//  MasterViewController.m
//  LinphoneTester
//
//  Created by guillaume on 28/05/2014.
//
//

#import "MasterViewController.h"
#import "LogsViewController.h"
#import "DetailViewController.h"

#include "linphone/liblinphone_tester.h"
#include "mediastreamer2/msutils.h"
#import "Utils.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
    NSString* bundlePath;
    NSString* documentPath;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

NSMutableArray* lastLogs = nil;
NSMutableArray* logsBuffer = nil;
static int const kLastLogsCapacity = 5000;
static int const kLogsBufferCapacity = 10;
NSString* const  kLogsUpdateNotification = @"kLogsUpdateNotification";

- (void)setupLogging {
    lastLogs = [[NSMutableArray alloc] initWithCapacity:kLastLogsCapacity];
    logsBuffer = [NSMutableArray arrayWithCapacity:kLogsBufferCapacity];

	linphone_core_set_log_level(ORTP_WARNING);
	linphone_core_set_log_handler((OrtpLogFunc)linphone_iphone_log_handler);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [self setupLogging];
    
    bundlePath = [[NSBundle mainBundle] bundlePath];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentPath = [paths objectAtIndex:0];

	bc_tester_init((void (*)(int, const char *fm, va_list))linphone_iphone_log_handler, ORTP_MESSAGE, ORTP_ERROR);
	liblinphone_tester_add_suites();
		
	bc_tester_read_dir_prefix = ms_strdup([bundlePath UTF8String]);
	bc_tester_writable_dir_prefix = ms_strdup([documentPath UTF8String]);

	LOGI(@"Bundle path: %@", bundlePath);
	LOGI(@"Document path: %@", documentPath);

	int count = bc_tester_nb_suites();
	_objects = [[NSMutableArray alloc] initWithCapacity:count + 1];
	[_objects addObject:@"All"];
	for (int i = 0; i < count; i++) {
		const char *suite = bc_tester_suite_name(i);
		[_objects addObject:[NSString stringWithUTF8String:suite]];
	}
}

- (void)displayLogs {
	LOGI(@"Should display logs");
	[self.navigationController performSegueWithIdentifier:@"viewLogs" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSString *suite = _objects[indexPath.row];
    cell.textLabel.text = suite;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSString *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}


@end
