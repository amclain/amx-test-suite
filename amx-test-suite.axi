(***********************************************************
    AMX TEST SUITE
    v0.1.0

    Website: https://sourceforge.net/projects/[FUTURE]
    
    
 -- THIS IS A THIRD-PARTY LIBRARY AND IS NOT AFFILIATED WITH --
 --                   THE AMX ORGANIZATION                   --
    
    
    This suite contains functions to test code written for
    AMX NetLinx devices.
    
    Connect to the NetLinx device via TCP port 6000.  Type
    "run" (no quotes) to execute tests.
    
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

dvTestUser	= 0:6000:0; // User telnet port.
dvTestApp	= 0:6001:0; // Future.

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

TCPIP		= 1;
testUserPort	= 6000; // User telnet port.
testAppPort	= 6001; // Future.

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

char testUserBuf[1024];

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
 * Print a line to the telnet session.
 */
define_function sinteger testPrint(char line[])
{
    send_string dvTestUser, "line, $0d, $0a";
    return 0;
}

/*
 * Print symbol prompting for user input.
 */
define_function sinteger testPrintInput()
{
    send_string dvTestUser, "'> '";
    return 0;
}

/*
 * Print the running test name.
 */
define_function sinteger testPrintName(name[])
{
    if (length_string(name) > 0) send_string dvTestUser, "'Testing: ', name, $0d, $0a";
    return 0;
}

/*
 * Print 'passed'.
 */
define_function sinteger testPass()
{
    testsPass++;
    
    send_string dvTestUser, "'Passed', $0d, $0a, $0d, $0a";
    return TEST_PASS;
}

/*
 * Print 'failed'.
 */
define_function sinteger testFail()
{
    testsFail++;
    
    send_string dvTestUser, "'--FAILED--', $0d, $0a, $0d, $0a";
    return TEST_FAIL;
}

/*
 * Parse user buffer.
 */
define_function sinteger testParseUserBuffer()
{
    if (find_string(testUserBuf, "$0d", 1) == 0 && find_string(testUserBuf, "$0a", 1) == 0) return 0;
    
    if (find_string(testUserBuf, 'help', 1) > 0 || find_string(testUserBuf, '?', 1) > 0)
    {
	testPrint('--------------');
	testPrint('   COMMANDS   ');
	testPrint('--------------');
	testPrint('run');
	testPrint('Starts the tests.');
	testPrint('');
	testPrintInput();
	
	clear_buffer testUserBuf;
    }
    
    if (find_string(testUserBuf, 'run', 1))
    {
	testPrint('Running tests...');
	
	//testRun(); // Call the user-defined function to start tests.
	
	testPrint('Done.');
	testPrint('');
	testPrintInput();
	
	clear_buffer testUserBuf;
    }
    
    /////////////////////
    // TODO: Revise this.
    /////////////////////
    if (length_string(testUserBuf) > 0)
    {
	testPrint('Unknown command.');
	testPrintInput();
	clear_buffer testUserBuf;
    }
    
    return 0;
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

create_buffer dvTestUser, testUserBuf;

ip_server_open(testUserPort, testUserPort, TCPIP);
//ip_server_open(testAppPort, testAppPort, TCPIP); // Future.

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[dvTestUser]
{
    online:
    {
	testPrint('Connected to test suite.');
	testPrintInput();
    }
    
    string:
    {
	if (data.text != $0d && data.text != $0a)
	{
	    send_string dvTestUser, "data.text"; // Echo text to user.
	}
	else
	{
	    send_string dvTestUser, "$0d, $0a";
	    testParseUserBuffer();
	}
    }
    
    offline:
    {
	clear_buffer testUserBuf;
	ip_server_open(testUserPort, testUserPort, TCPIP);
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

