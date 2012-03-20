(***********************************************************
    AMX NETLINX TEST SUITE
    TESTS
    
    Website: https://sourceforge.net/projects/amx-test-suite/
    
    
    These functions test the application's functionality.
    
    >>  Run the tests in verbose mode (run -v) to verify  <<
    >>  that assertions pass and fail correctly.          <<
************************************************************)

PROGRAM_NAME='test-suite-tests'
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
(*                   INCLUDES GO BELOW                     *)
(***********************************************************)

#include 'amx-test-suite';

(***********************************************************)
(*           DEVICE NUMBER DEFINITIONS GO BELOW            *)
(***********************************************************)
DEFINE_DEVICE

vdvEventTester = 34000:1:0; // Virtual device for event asserts.

(***********************************************************)
(*                TEST DEFINITIONS GO BELOW                *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

define_function testSuiteRun()
{
    testBooleanAsserts();
    testComparisonAsserts();
    testStringAsserts();
    testEventAsserts();
}

define_function testBooleanAsserts()
{
    // Assert alias.
    assert(true, 'Assert alias.');
    assert(false, 'Assert alias (FAIL).');
    
    // Assert true.
    assertTrue(true, 'Assert boolean true.');
    assertTrue(1, 'Assert integer 1.');
    assertTrue(2, 'Assert integer > 1.');
    assertTrue(0, 'Assert True = 0 (FAIL).');
    
    // Assert false.
    assertFalse(false, 'Assert boolean false.');
    assertFalse(0, 'Assert integer 0.');
    assertFalse(-1, 'Assert integer < 0');
    assertFalse(1, 'Assert False = 1 (FAIL).');
}

define_function testComparisonAsserts()
{
    // Assert equal.
    assertEqual(1, 1, 'Assert equal.');
    assertEqual(2, 10, 'Assert equal (FAIL).');
    
    // Assert not equal.
    assertNotEqual(3, 6, 'Assert not equal.');
    assertNotEqual(7, 7, 'Assert not equal (FAIL).');
    
    // Assert greater than.
    assertGreater(8, 4, 'Assert greater.');
    assertGreater(1, 6, 'Assert greater (FAIL).');
    assertGreater(5, 5, 'Assert greater (FAIL): equal.');
    
    // Assert greater than or equal to.
    assertGreaterEqual(9, 2, 'Assert greater equal.');
    assertGreaterEqual(14, 14, 'Assert greater equal: equal.');
    assertGreaterEqual(11, 19, 'Assert greater equal (FAIL).');
    
    // Assert less than.
    assertLess(6, 15, 'Assert less.');
    assertLess(23, 12, 'Assert less (FAIL).');
    assertLess(8, 8, 'Assert less (FAIL): equal.');
    
    // Assert less than or equal to.
    assertLessEqual(20, 31, 'Assert less equal.');
    assertLessEqual(23, 23, 'Assert less equal: equal.');
    assertLessEqual(87, 60, 'Assert less equal (FAIL).');
}

define_function testStringAsserts()
{
    // String alias.
    assertString('abc def', 'abc def', 'String alias.');
    assertString('abc def', 'abc 123', 'String alias (FAIL).');
    
    // String equal.
    assertStringEqual('abc def', 'abc def', 'Assert string equal.');
    assertStringEqual('abc def', 'abc 456', 'Assert string equal (FAIL).');
    
    // String not equal.
    assertStringNotEqual('abc def', 'abc 456', 'Assert string not equal.');
    assertStringNotEqual('abc def', 'abc def', 'Assert string not equal (FAIL).');
    
    // String contains.
    assertStringContains('abc def', 'def', 'Assert string contains.');
    assertStringContains('abc def', '123', 'Assert string contains (FAIL).');
    
    // String does not contain.
    assertStringNotContains('abc def', '123', 'Assert string not contains.');
    assertStringNotContains('abc def', 'def', 'Assert string not contains (FAIL).');
}

define_function testEventAsserts()
{
    // Data event: String.
    send_string vdvEventTester, 'ABC123EVENT';
    assertEvent(vdvEventTester, TEST_SUITE_EVENT_STRING, TEST_SUITE_NULL, 'ABC123EVENT', 'Assert event.');
    
    // Data event: String, FAIL.
    // Incorrect data returned.
    send_string vdvEventTester, 'ABC123EVENT';
    assertEvent(vdvEventTester, TEST_SUITE_EVENT_STRING, TEST_SUITE_NULL, '456', 'Assert event (FAIL).');
    
    // Data event: String, FAIL.
    // Event never triggered (don't handle event).
}

(***********************************************************)
(*                   THE EVENTS GO BELOW                   *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[vdvEventTester]
{
    STRING:
    {
	testSuiteEventTriggered(vdvEventTester, TEST_SUITE_EVENT_STRING, TEST_SUITE_NULL, data.text);
    }
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*          DO NOT PUT ANY CODE BELOW THIS COMMENT         *)
(***********************************************************)
