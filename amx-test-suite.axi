(***********************************************************
    AMX TEST SUITE
    v0.1.0

    Website: https://sourceforge.net/projects/[FUTURE]
    
    
 -- THIS IS A THIRD-PARTY LIBRARY AND IS NOT AFFILIATED WITH --
 --                   THE AMX ORGANIZATION                   --
    
    
    This suite contains functions to test code written for
    AMX NetLinx devices.
    
    Connect to the NetLinx device via TCP port 60000.  Type
    "run" (no quotes) to execute tests.
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

dvTestOut	= 0:60000:0; // User telnet port.
dvTestApp	= 0:60001:0; // Future.

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

TCPIP		= 1;
testOutPort	= 60000; // User telnet port.
testAppPort	= 60001; // Future.

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
 * Print a line to the telnet session.
 */
define_function sinteger testPrint(char line[])
{
    send_string dvTestOut, "line, $0d, $0a";
    return 0;
}

/*
 * Print symbol prompting for user input.
 */
define_function sinteger testPrintInput()
{
    send_string dvTestOut, "'> '";
    return 0;
}

/*
 * Print the running test name.
 */
define_function sinteger testPrintName(name[])
{
    send_string dvTestOut, "'Testing: ', name, $0d, $0a";
    return 0;
}

/*
 * Print 'passed'.
 */
define_function sinteger testPass()
{
    testsPass++;
    
    send_string dvTestOut, "'Passed', $0d, $0a, $0d, $0a";
    return TEST_PASS;
}

/*
 * Print 'failed'.
 */
define_function sinteger testFail()
{
    testsFail++;
    
    send_string dvTestOut, "'--FAILED--', $0d, $0a, $0d, $0a";
    return TEST_FAIL;
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

}

define_function sinteger assertNotEqual(slong x, slong y, char name[])
{

}

define_function sinteger assertGreater(slong x, slong y, char name[])
{

}

define_function sinteger assertGreaterEqual(slong x, slong y, char name[])
{

}

define_function sinteger assertLess(slong x, slong y, char name[])
{

}

define_function sinteger assertLessEqual(slong x, slong y, char name[])
{

}

define_function sinteger assertString(char x[], char y[], name[])
{
    return assertStringEqual(x, y, name);
}

define_function sinteger assertStringEqual(char x[], char y[], name[])
{

}

define_function sinteger assertStringNotEqual(char x[], char y[], name[])
{

}

define_function sinteger assertStringContains(char x[], char y[], name[])
{

}

define_function sinteger assertStringNotContains(char x[], char y[], name[])
{

}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

ip_server_open(testOutPort, testOutPort, TCPIP);
//ip_server_open(testAppPort, testAppPort, TCPIP); // Future.

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[dvTestOut]
{
    online:
    {
	testPrint('Connected to test suite.');
	testPrintInput();
    }
    
    string:
    {
	send_string dvTestOut, "data.text"; // Echo text to user.
	
	if (find_string(data.text, 'help', 1) | find_string(data.text, '?', 1))
	{
	    testPrint('--------------');
	    testPrint('   COMMANDS   ');
	    testPrint('--------------');
	    testPrint('run');
	    testPrint('Starts the tests.');
	    testPrint('');
	    testPrintInput();
	}
	
	if (find_string(data.text, 'run', 1))
	{
	    testPrint('Running tests...');
	    testPrint('Done.');
	    testPrintInput();
	}
    }
    
    offline:
    {
	ip_server_open(testOutPort, testOutPort, TCPIP);
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

