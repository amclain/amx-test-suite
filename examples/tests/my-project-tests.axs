(***********************************************************
    AMX NETLINX TEST SUITE
    EXAMPLE

    Website: https://sourceforge.net/projects/amx-test-suite/
    
    
    The "my-project-tests" workspace contains testing code
    that would be loaded onto a master to verify that
    functions in the production code return the correct
    values.
    
    See the "my-project" workspace for an example of the
    production setup.
    
    See the "amx-test-suite" include file and/or website
    documentation for help compiling and loading this
    example test on a master.
    
    From the NetLinx Diagnostics Program, send the string
    "run -v" (no quotes) to watch all tests.
************************************************************)

PROGRAM_NAME='my-project-tests'

#include 'amx-test-suite'
#include 'my-project-functions'

(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

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
 *  This function is the user-defined entry point for the
 *  test harness.
 */
define_function testSuiteRun()
{
    // Test add() function.
    assert(add(1, 2) == 3, '1 + 2 = 3');
    
    // Test subtract() function.
    assert(subtract(5, 4) == 1, '5 - 4 = 1');
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

