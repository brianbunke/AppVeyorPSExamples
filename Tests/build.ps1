Write-Host "Branch: $env:APPVEYOR_REPO_BRANCH"
Write-Host "Author: $env:APPVEYOR_REPO_COMMIT_AUTHOR"

# Pester. Let's run some tests!
# https://github.com/pester/Pester/wiki/Showing-Test-Results-in-CI-(TeamCity,-AppVeyor)
# https://www.appveyor.com/docs/running-tests/#build-worker-api

# Make this a stupid, quick function to avoid repeating the code twice
function Pester-AppVeyor ($Tag) {
    # Invoke-Pester runs all .Tests.ps1 in the order found by "Get-ChildItem -Recurse"
    $TestResults = Invoke-Pester -Tag $Tag -OutputFormat NUnitXml -OutputFile ".\TestResults.xml" -PassThru
    # Upload the XML file of test results to the current AppVeyor job
    (New-Object 'System.Net.WebClient').UploadFile(
        "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
        (Resolve-Path ".\TestResults.xml") )
    # If a Pester test failed, use "throw" to end the script here, before deploying
    If ($TestResults.FailedCount -gt 0) {
        throw "$($TestResults.FailedCount) Pester test(s) failed."
    }
}

Pester-AppVeyor -Tag 'unit'

# Stop here if this isn't the master branch, or if this is a pull request
If ($env:APPVEYOR_REPO_BRANCH -ne 'master') {
    Write-Verbose "Skipping integration tests for branch $env:APPVEYOR_REPO_BRANCH"
} ElseIf ($env:APPVEYOR_PULL_REQUEST_NUMBER -gt 1) {
    Write-Verbose "Skipping integration tests for pull request #$env:APPVEYOR_PULL_REQUEST_NUMBER"
} Else {
    # Invoke-Pester against the integration tests
    Pester-AppVeyor -Tag 'integration'
}
