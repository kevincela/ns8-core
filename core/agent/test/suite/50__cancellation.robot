*** Settings ***
Resource         taskrun.resource
Suite Setup      Start the agent
Suite Teardown   Stop the agent and cleanup
Test Setup       Start command monitoring
Test Teardown    Stop command monitoring and flush the database

*** Variables ***
${AGENT_ID}    %{AGENT_ID}

*** Test Cases ***
Cancel a long running task
    Given The task is submitted    run-longlasting
    And The command is received    set    run-longlasting/context
    And The command is received    publish    id-run-longlasting    status    pending
    And The command is received    publish    id-run-longlasting    status    running
    When The task is submitted      cancel-task    {"task":"id-run-longlasting","timeout":2}
    And The command is received    publish    id-cancel-task    status    running
    And The command is received    publish    run-longlasting    status    aborted
    Then Wait until the agent log contains    "run-longlasting" status is "aborted"

Cancel a non-existing task
    Given The task is submitted    cancel-task    {"task":"id-non-existing","timeout":2}
    When The command is received    set    id-cancel-task/exit_code    2
    And The command is received    publish    id-cancel-task    status    validation-failed
    Then Wait until the agent log contains    task ID not found

Start cancel-task with bad input
    Given The task is submitted    cancel-task    {"Mask":"Mask is a typo","timeout":2}
    When The command is received    set    id-cancel-task/exit_code    10
    And The command is received    publish    id-cancel-task    status    validation-failed
    Then Wait until the agent log contains    invalid task ID or timeout value
