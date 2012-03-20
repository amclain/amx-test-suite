(***********************************************************
    AMX NETLINX TEST SUITE
    v1.0.0

    Website: https://sourceforge.net/projects/amx-test-suite/
    
    
 -- THIS IS A THIRD-PARTY LIBRARY AND IS NOT AFFILIATED WITH --
 --                   THE AMX ORGANIZATION                   --
    
    
    This suite contains functionality to test code written for
    AMX NetLinx devices.
    
    Tests are created in a user-defined file with a call to
    function testSuiteRun().  Use the assert functions below
    to verify your code's behavior.
    
    TO START THE TESTS:
    Compile your test project and load it on a master device.
    Launch the NetLinx Diagnostics Program provided by AMX and
    connect to the master.  When connected, click the "Enable
    Internal System Diagnostics" button.  In the "Control
    Device" page, set the device to control as follows:
    
    Device 36000
    Port   1
    System 0
    
    In the message to send box, type "run" (no quotes), select
    string as the type, and send the string to the device.
    The test results will be displayed in the "Diagnostics"
    window.
*************************************************************
    Copyright 2011 Alex McLain
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
************************************************************)

PROGRAM_NAME='amx-test-suite'

#if_not_defined AMX_TEST_SUITE
#define AMX_TEST_SUITE 1
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    History: See changelog.txt or version control repository.
*)
(***********************************************************)
(*           DEVICE NUMBER DEFINITIONS GO BELOW            *)
(***********************************************************)
DEFINE_DEVICE

dvTestSuiteDebug	= 0:0:0;     // Console output.
vdvTestSuiteListener	= 36000:1:0; // User command listener.

(***********************************************************)
(*              CONSTANT DEFINITIONS GO BELOW              *)
(***********************************************************)
DEFINE_CONSTANT

TEST_PASS	=  0;
TEST_FAIL	= -1;

TEST_SUITE_NULL	       = 0;
TEST_SUITE_NULL_STRING = '';

TEST_SUITE_TIMEOUT_DEFAULT = 1000; // Event timeout in ms.

// Test Suite Timelines //
TEST_SUITE_TIMELINE_TIMESTAMP = 1; // For timestamp (in ms).

// Test Suite Running States //
TEST_SUITE_IDLE	   = 0;
TEST_SUITE_RUNNING = 1;

// Test Suite Message Modes //
TEST_SUITE_MESSAGE_NORMAL  = 0; // Only print failed tests.
TEST_SUITE_MESSAGE_VERBOSE = 1; // Print all tests.

// Test Suite Event Types //
TEST_SUITE_EVENT_NULL		= 0
TEST_SUITE_EVENT_COMMAND	= 1;
TEST_SUITE_EVENT_STRING		= 2;
TEST_SUITE_EVENT_ONLINE		= 3;
TEST_SUITE_EVENT_OFFLINE	= 4;
TEST_SUITE_EVENT_ONERROR	= 5;
TEST_SUITE_EVENT_STANDBY	= 6;
TEST_SUITE_EVENT_AWAKE		= 7;
TEST_SUITE_EVENT_PUSH		= 8;
TEST_SUITE_EVENT_RELEASE	= 9;
TEST_SUITE_EVENT_HOLD		= 10;
TEST_SUITE_EVENT_ON		= 11;
TEST_SUITE_EVENT_OFF		= 12;
TEST_SUITE_EVENT_LEVEL		= 13;

// Test Suite Event Status //
TEST_SUITE_ESTAT_ASSERTED	=  2;
TEST_SUITE_ESTAT_PENDING	=  1;
TEST_SUITE_ESTAT_VACANT		=  0;	// Index can be overwritten.
TEST_SUITE_ESTAT_FAILED		= -1;
TEST_SUITE_ESTAT_EXPIRED	= -2;

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

// Used for testing events.
struct testSuiteEvent
{
    char name[255];	// Assertion name.
    dev device;		// Device triggering the event.
    sinteger status;	// See test suite event status constants.
    integer type;	// See test suite event type constants.
    char str[1024];	// Data: Used for strings.
    char level;		// Data: Used for levels.
    long timestamp;	// Time the event was created.
    long expiration;	// Timestamp value that the event expires on.
}

(***********************************************************)
(*              VARIABLE DEFINITIONS GO BELOW              *)
(***********************************************************)
DEFINE_VARIABLE

long testSuiteTimestamp = 0;		// Timestamp timer.
long testSuiteTimestampResolution[] = {1};	// 1 ms resolution.

slong testsPass;
slong testsFail;

char testSuiteRunning = TEST_SUITE_IDLE;		// See test suite runnning states.
char testSuiteMessageMode = TEST_SUITE_MESSAGE_NORMAL;	// See test suite message modes.

// These arrays take up a lot of memory (>500k).
// Store them in RAM instead of non-volatile.
volatile testSuiteEvent testSuiteEventAsserts[255];
volatile testSuiteEvent testSuiteEventQueue[255];

(***********************************************************)
(*         SUBROUTINE/FUNCTION DEFINITIONS GO BELOW        *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)
DEFINE_MUTUALLY_EXCLUSIVE

/*
 *  Print a line to the NetLinx diagnostic window.
 */
define_function testSuitePrint(char line[])
{
    send_string dvTestSuiteDebug, "line";
}

/*
 *  Print the running test name.
 */
define_function testSuitePrintName(char name[])
{
    if (length_string(name) > 0) send_string dvTestSuiteDebug, "'Testing: ', name";
}

/*
 *  Print 'passed'.
 */
define_function sinteger testSuitePass(char name[])
{
    testsPass++;
    
    if (testSuiteMessageMode == TEST_SUITE_MESSAGE_VERBOSE)
    {
	testSuitePrintName(name);
	send_string dvTestSuiteDebug, "'Passed.'";
    }
    
    return TEST_PASS;
}

/*
 *  Print 'failed'.
 */
define_function sinteger testSuiteFail(char name[])
{
    testsFail++;
    
    testSuitePrintName(name);
    send_string dvTestSuiteDebug, "'--FAILED--'";
    return TEST_FAIL;
}

/*
 *  Reset the test counters.
 */
define_function testSuiteResetCounters()
{
    testsFail = 0;
    testsPass = 0;
}

/*
 *  Parse user command.
 */
define_function testSuiteParseUserCommand(char str[])
{
    if (testSuiteRunning == TEST_SUITE_RUNNING) return;
    
    if (find_string(str, 'help', 1) > 0 || find_string(str, '?', 1) > 0)
    {
	testSuitePrintCommands();
    }
    
    if (find_string(str, 'run', 1))
    {
	if (length_string(str) < 6)
	{
	    // No flags.  Run in normal mode.
	    testSuiteMessageMode = TEST_SUITE_MESSAGE_NORMAL;
	}
	else
	{
	    // Check for verbose mode.
	    if (find_string(str, 'v', 1))
	    {
		testSuiteMessageMode = TEST_SUITE_MESSAGE_VERBOSE;
	    }
	}
	
	testSuiteStartTests();
    }
}

/*
 *  Print the list of test suite commands.
 */
define_function testSuitePrintCommands()
{
    testSuitePrint('--------------------------------------------------');
    testSuitePrint('               TEST SUITE COMMANDS                ');
    testSuitePrint('--------------------------------------------------');
    testSuitePrint('help                                              ');
    testSuitePrint('   Display this list of test suite commands.      ');
    testSuitePrint('                                                  ');
    testSuitePrint('run [-v]                                          ');
    testSuitePrint('   Start the tests.                               ');
    testSuitePrint('   -v   Verbose mode: Show tests that pass.       ');
    testSuitePrint('--------------------------------------------------');
}

/*
 *  Run the tests.
 */
define_function testSuiteStartTests()
{
    if (testSuiteRunning == TEST_SUITE_RUNNING) return;
    
    testSuiteRunning = TEST_SUITE_RUNNING; // Flag tests as running.
    
    testSuiteResetCounters();
    
    testSuitePrint('Running tests...');
    
    testSuiteRun(); // Call the user-defined function to start tests.
    
    testSuitePrint("'Total Tests: ', itoa(testsPass + testsFail), '   Tests Passed: ', itoa(testsPass), '   Tests Failed: ', itoa(testsFail)");
    testSuitePrint('Done.');
    
    testSuiteRunning = TEST_SUITE_IDLE; // Flag tests as completed.
}

/*
 *  A device event was triggered.  Add the event to the queue.
 */
define_function testSuiteEventTriggered(dev device, integer type, char level, char str[])
{
    integer i;
    i = 1;
    
    // Make sure event slot isn't occupied before writing.
    while (testSuiteEventQueue[i].status != TEST_SUITE_ESTAT_VACANT)
    {
	i++;
	
	// Break if buffer is full to prevent endless loop.
	if (i > max_length_array(testSuiteEventQueue))
	{
	    testSuitePrint('--EVENT QUEUE OVERFLOW--');
	    return;
	}
    }

    testSuiteEventQueue[i].timestamp = testSuiteTimestamp;
    testSuiteEventQueue[i].expiration = testSuiteTimestamp + TEST_SUITE_TIMEOUT_DEFAULT;
    testSuiteEventQueue[i].status = TEST_SUITE_ESTAT_PENDING;
    testSuiteEventQueue[i].type = type;
    testSuiteEventQueue[i].device = device;
    testSuiteEventQueue[i].str = str;
    testSuiteEventQueue[i].level = level;
}

/*
 *  Process any pending event assertions and garbage-collect the queues.
 */
define_function testSuiteProcessEventAssertions()
{
    integer i, j;
    
    for (i = 1; i <= max_length_array(testSuiteEventAsserts); i++)
    {
	// Check for pending assertions.
	if (testSuiteEventAsserts[i].status == TEST_SUITE_ESTAT_PENDING)
	{
	    for (j = 1; j <= max_length_array(testSuiteEventQueue); j++)
	    {
		// Check for event match.
		if (testSuiteEventAsserts[i].device == testSuiteEventQueue[j].device &&
		    testSuiteEventAsserts[i].type == testSuiteEventQueue[j].type &&
		    testSuiteEventAsserts[i].level == testSuiteEventQueue[j].level &&
		    testSuiteEventAsserts[i].str == testSuiteEventQueue[j].str)
		{
		    testSuitePass(testSuiteEventAsserts[i].name);
		    
		    testSuiteEventAsserts[i].status = TEST_SUITE_ESTAT_ASSERTED;
		    testSuiteEventQueue[j].status = TEST_SUITE_ESTAT_ASSERTED;
		    
		    break;
		}
	    }
	}
    }
    
    // Do garbage collection.
    testSuiteGarbageCollectEventQueue(testSuiteEventAsserts);
    testSuiteGarbageCollectEventQueue(testSuiteEventQueue);
}

/*
 *  Performs garbage collection on the specified queue.
 */
define_function testSuiteGarbageCollectEventQueue(testSuiteEvent queue[])
{
    integer i;
    
    for (i = 1; i <= max_length_array(queue); i++)
    {
	// Check for empty slot.
	if (queue[i].status == TEST_SUITE_ESTAT_VACANT)
	{
	    continue; // Skip.
	}
	
	// Check for expired event.
	if (queue[i].expiration < testSuiteTimestamp)
	{
	    // Check if event was an assertion (name attached).
	    if (length_string(queue[i].name) > 0)
	    {
		// Fail the assertion.
		testSuiteFail(queue[i].name);
	    }
	    
	    queue[i].status = TEST_SUITE_ESTAT_EXPIRED;
	}
	
	// Check for pending slot.
	if (queue[i].status == TEST_SUITE_ESTAT_PENDING)
	{
	    continue; // Skip.
	}
	
	// Free the slot.
	queue[i].device = 0;
	queue[i].expiration = 0;
	queue[i].level = 0;
	queue[i].name = '';
	queue[i].str = '';
	queue[i].timestamp = 0;
	queue[i].type = 0;
	
	queue[i].status = TEST_SUITE_ESTAT_VACANT;
    }
}

(***********************************************************)
(*                 TEST SUITE ASSERTIONS                   *)
(***********************************************************)

/*
 *  Alias of assertTrue().
 */
define_function sinteger assert(slong x, char name[])
{
    return assertTrue(x, name);
}

/*
 *  Passes if x is true (x > 0).  This means success codes
 *  can be defined as positive numbers. x can also be an
 *  expression, for example:
 *  assertTrue(myVariable == 10, 'Test my variable.');
 */
define_function sinteger assertTrue(slong x, char name[])
{
    if (x > 0)
    {
	return testSuitePass(name);
    }
    else
    {
	return testSuiteFail(name);
    }
}

/*
 *  Passes if x is false (x <= 0).  If error codes are defined
 *  as negative numbers, this test will also pass.  x can also
 *  be an expression (see assertTrue() function).
 */
define_function sinteger assertFalse(slong x, char name[])
{
    if (x <= 0)
    {
	return testSuitePass(name);
    }
    else
    {
	return testSuiteFail(name);
    }
}

/*
 *  Passes if x and y are equal.
 *  x == y
 */
define_function sinteger assertEqual(slong x, slong y, char name[])
{
    if (x == y)
    {
	return testSuitePass(name);
    }
    else
    {
	return testSuiteFail(name);
    }
}

/*
 *  Passes if x and y are not equal.
 *  x != y
 */
define_function sinteger assertNotEqual(slong x, slong y, char name[])
{
    if (x != y)
    {
	return testSuitePass(name);
    }
    else
    {
	return testSuiteFail(name);
    }
}

/*
 *  Passes if x is greater than y.
 *  x > y
 */
define_function sinteger assertGreater(slong x, slong y, char name[])
{
    if (x > y)
    {
	return testSuitePass(name);
    }
    else
    {
	return testSuiteFail(name);
    }
}

/*
 *  Passes if x is greater than or equal to y.
 *  x >= y
 */
define_function sinteger assertGreaterEqual(slong x, slong y, char name[])
{
    if (x >= y)
    {
	return testSuitePass(name);
    }
    else
    {
	return testSuiteFail(name);
    }
}

/*
 *  Passes if x is less than y.
 *  x < y
 */
define_function sinteger assertLess(slong x, slong y, char name[])
{
    if (x < y)
    {
	return testSuitePass(name);
    }
    else
    {
	return testSuiteFail(name);
    }
}

/*
 *  Passes if x is less than or equal to y.
 *  x <= y
 */
define_function sinteger assertLessEqual(slong x, slong y, char name[])
{
    if (x <= y)
    {
	return testSuitePass(name);
    }
    else
    {
	return testSuiteFail(name);
    }
}

/*
 *  Alias of assertStringEqual().
 */
define_function sinteger assertString(char x[], char y[], char name[])
{
    return assertStringEqual(x, y, name);
}

/*
 *  Passes if string x[] is identical to string y[].
 *  x[] == y[]
 */
define_function sinteger assertStringEqual(char x[], char y[], char name[])
{
    if (compare_string(x, y) == 1)
    {
	return testSuitePass(name);
    }
    else
    {
	return testSuiteFail(name);
    }
}

/*
 *  Passes if string x[] is not identical to string y[].
 *  x[] != y[]
 */
define_function sinteger assertStringNotEqual(char x[], char y[], char name[])
{
    if (compare_string(x, y) == 0)
    {
	return testSuitePass(name);
    }
    else
    {
	return testSuiteFail(name);
    }
}

/*
 *  Passes if string x[] contains string y[].
 *  y[] is in x[]
 */
define_function sinteger assertStringContains(char x[], char y[], char name[])
{
    if (find_string(x, y, 1) >= 1)
    {
	return testSuitePass(name);
    }
    else
    {
	return testSuiteFail(name);
    }
}

/*
 *  Passes if string x[] does not contain string y[].
 *  y[] not in x[]
 */
define_function sinteger assertStringNotContains(char x[], char y[], char name[])
{
    if (find_string(x, y, 1) == 0)
    {
	return testSuitePass(name);
    }
    else
    {
	return testSuiteFail(name);
    }
}

/*
 *  Adds an event to the assertion queue.
 */
define_function assertEvent(dev device, integer type, char level, char str[], char name[])
{
    integer i;
    i = 1;
    
    // Make sure event slot isn't occupied before writing.
    while (testSuiteEventAsserts[i].status != TEST_SUITE_ESTAT_VACANT)
    {
	i++;
	
	// Break if buffer is full to prevent endless loop.
	if (i > max_length_array(testSuiteEventAsserts))
	{
	    testSuitePrint('--ASSERT QUEUE OVERFLOW--');
	    return;
	}
    }

    testSuiteEventAsserts[i].timestamp = testSuiteTimestamp;
    testSuiteEventAsserts[i].expiration = testSuiteTimestamp + TEST_SUITE_TIMEOUT_DEFAULT;
    testSuiteEventAsserts[i].name = name;
    testSuiteEventAsserts[i].status = TEST_SUITE_ESTAT_PENDING;
    testSuiteEventAsserts[i].type = type;
    testSuiteEventAsserts[i].device = device;
    testSuiteEventAsserts[i].str = str;
    testSuiteEventAsserts[i].level = level;
}

(***********************************************************)
(*                 STARTUP CODE GOES BELOW                 *)
(***********************************************************)
DEFINE_START

testSuiteResetCounters();

timeline_create(TEST_SUITE_TIMELINE_TIMESTAMP, testSuiteTimestampResolution, 1, TIMELINE_RELATIVE, TIMELINE_REPEAT); // Setup the timestamp timer.

(***********************************************************)
(*                   THE EVENTS GO BELOW                   *)
(***********************************************************)
DEFINE_EVENT

data_event[vdvTestSuiteListener]
{
    string:
    {
	testSuiteParseUserCommand(data.text);
    }
}

timeline_event[TEST_SUITE_TIMELINE_TIMESTAMP]
{
    testSuiteTimestamp++;
    testSuiteProcessEventAssertions();
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*          DO NOT PUT ANY CODE BELOW THIS COMMENT         *)
(***********************************************************)
#end_if
