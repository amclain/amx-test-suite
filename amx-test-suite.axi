(***********************************************************
    AMX TEST SUITE
    v0.1.0

    Website: https://sourceforge.net/projects/[FUTURE]
    
    
 -- THIS IS A THIRD-PARTY LIBRARY AND IS NOT AFFILIATED WITH --
 --                   THE AMX ORGANIZATION                   --
    
    
    This suite contains functions to test code written for
    AMX NetLinx devices.
    
    Connect to the NetLinx device via TCP port 5000.  Type
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

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

long testsPass;
long testsFail;

char testsRunning; // Tests are currently running.

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
define_function sinteger testsPrint(char line[])
{
    send_string dvTestOut, "line, $0d, $0a";
    return 0;
}

/*
 * Print symbol prompting for user input.
 */
define_function sinteger testsPrintInput()
{
    send_string dvTestOut, "'> '";
    return 0;
}

(***********************************************************)
(*                   TESTING FUNCTIONS                     *)
(***********************************************************)

define_function sinteger assert(long x, long y, char name[])
{
    return assertEqual(x, y, name);
}

define_function sinteger assertTrue(long x, char name[])
{

}

define_function sinteger assertFalse(long x, char name[])
{

}

define_function sinteger assertEqual(long x, long y, char name[])
{

}

define_function sinteger assertNotEqual(long x, long y, char name[])
{

}

define_function sinteger assertGreater(long x, long y, char name[])
{

}

define_function sinteger assertGreaterEqual(long x, long y, char name[])
{

}

define_function sinteger assertLess(long x, long y, char name[])
{

}

define_function sinteger assertLessEqual(long x, long y, char name[])
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
	testsPrint('Connected to test suite.');
	testsPrintInput();
    }
    
    string:
    {
	send_string dvTestOut, "data.text"; // Echo text to user.
	
	if (find_string(data.text, 'help', 1) | find_string(data.text, '?', 1))
	{
	    testsPrint('--------------');
	    testsPrint('   COMMANDS   ');
	    testsPrint('--------------');
	    testsPrint('run');
	    testsPrint('Starts the tests.');
	    testsPrint('');
	    testsPrintInput();
	}
	
	if (find_string(data.text, 'run', 1))
	{
	    testsPrint('Running tests...');
	    testsPrint('Done.');
	    testsPrintInput();
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

