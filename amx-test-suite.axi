(***********************************************************
    AMX TEST SUITE
    v0.1.0

    Website: https://sourceforge.net/projects/[FUTURE]
    
    
 -- THIS IS A THIRD-PARTY LIBRARY AND IS NOT AFFILIATED WITH --
 --                   THE AMX ORGANIZATION                   --
    
    
    This suite contains functions to test code written for
    AMX NetLinx devices.
    
    TO START THE TESTS:
    Set the NetLinx Diagnostics "Control Device" page to
    device 36000, port 1, system 0.  In the message to send
    box, type "run" (no quotes), select string as the type,
    and send the string to the device.
    
    Tests are created in a user-defined file with a call to
    function testRun().
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
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    History: See version control repository.
*)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvTestDebug	= 0:0:0;     // Debug output.
vdvListener	= 36000:1:0; // User command listener.

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

TEST_PASS	=  0;
TEST_FAIL	= -1;

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

slong testsPass;
slong testsFail;

char testsRunning; // Is > 0 if tests are currently running.

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

/*
 * Print a line to the NetLinx diagnostic window.
 */
define_function testPrint(char line[])
{
    send_string dvTestDebug, "line";
}

/*
 * Print symbol prompting for user input.
 * DEPRECATED
 */
define_function testPrintInput()
{
    send_string dvTestDebug, "'> '";
}

/*
 * Print the running test name.
 */
define_function testPrintName(name[])
{
    if (length_string(name) > 0) send_string dvTestDebug, "'Testing: ', name";
}

/*
 * Print 'passed'.
 */
define_function sinteger testPass()
{
    testsPass++;
    
    send_string dvTestDebug, "'Passed.'";
    return TEST_PASS;
}

/*
 * Print 'failed'.
 */
define_function sinteger testFail()
{
    testsFail++;
    
    send_string dvTestDebug, "'--FAILED--'";
    return TEST_FAIL;
}

/*
 * Parse user buffer.
 */
define_function testParseUserCommand(char str[])
{
    if (find_string(str, 'help', 1) > 0 || find_string(str, '?', 1) > 0)
    {
	testPrint('--------------------------------------------------');
	testPrint('                     COMMANDS                     ');
	testPrint('--------------------------------------------------');
	testPrint('help                                              ');
	testPrint('   Display this list of test suite commands.      ');
	testPrint('                                                  ');
	testPrint('run                                               ');
	testPrint('   Start the tests.                               ');
	testPrint('--------------------------------------------------');
    }
    
    if (find_string(str, 'run', 1))
    {
	testPrint('Running tests...');
	
	testsRunning = 1; // Flag tests as running.
	
	testRun(); // Call the user-defined function to start tests.
	
	testsRunning = 0; // Flag tests as completed.
	
	testPrint("'Total Tests: ', itoa(testsPass + testsFail), '   Tests Passed: ', itoa(testsPass), '   Tests Failed: ', itoa(testsFail)");
	testPrint('Done.');
	
	// Reset test counters.
	testsPass = 0;
	testsFail = 0;
    }
}

(***********************************************************)
(*                   TESTING FUNCTIONS                     *)
(***********************************************************)

define_function sinteger assert(slong x, char name[])
{
    return assertTrue(x, name);
}

define_function sinteger assertTrue(slong x, char name[])
{
    testPrintName(name);
    
    if (x > 0)
    {
	return testPass();
    }
    else
    {
	return testFail();
    }
}

define_function sinteger assertFalse(slong x, char name[])
{
    testPrintName(name);
    
    if (x <= 0)
    {
	return testPass();
    }
    else
    {
	return testFail();
    }
}

define_function sinteger assertEqual(slong x, slong y, char name[])
{
    testPrintName(name);
    
    if (x == y)
    {
	return testPass();
    }
    else
    {
	return testFail();
    }
}

define_function sinteger assertNotEqual(slong x, slong y, char name[])
{
    testPrintName(name);
    
    if (x != y)
    {
	return testPass();
    }
    else
    {
	return testFail();
    }
}

define_function sinteger assertGreater(slong x, slong y, char name[])
{
    testPrintName(name);
    
    if (x > y)
    {
	return testPass();
    }
    else
    {
	return testFail();
    }
}

define_function sinteger assertGreaterEqual(slong x, slong y, char name[])
{
    testPrintName(name);
    
    if (x >= y)
    {
	return testPass();
    }
    else
    {
	return testFail();
    }
}

define_function sinteger assertLess(slong x, slong y, char name[])
{
    testPrintName(name);
    
    if (x < y)
    {
	return testPass();
    }
    else
    {
	return testFail();
    }
}

define_function sinteger assertLessEqual(slong x, slong y, char name[])
{
    testPrintName(name);
    
    if (x <= y)
    {
	return testPass();
    }
    else
    {
	return testFail();
    }
}

define_function sinteger assertString(char x[], char y[], name[])
{
    return assertStringEqual(x, y, name);
}

define_function sinteger assertStringEqual(char x[], char y[], name[])
{
    testPrintName(name);
    
    if (compare_string(x, y) == 1)
    {
	return testPass();
    }
    else
    {
	return testFail();
    }
}

define_function sinteger assertStringNotEqual(char x[], char y[], name[])
{
    testPrintName(name);
    
    if (compare_string(x, y) == 0)
    {
	return testPass();
    }
    else
    {
	return testFail();
    }
}

define_function sinteger assertStringContains(char x[], char y[], name[])
{
    testPrintName(name);
    
    if (find_string(x, y, 1) >= 1)
    {
	return testPass();
    }
    else
    {
	return testFail();
    }
}

define_function sinteger assertStringNotContains(char x[], char y[], name[])
{
    testPrintName(name);
    
    if (find_string(x, y, 1) == 0)
    {
	return testPass();
    }
    else
    {
	return testFail();
    }
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[vdvListener]
{
    string:
    {
	testParseUserCommand(data.text);
    }
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

