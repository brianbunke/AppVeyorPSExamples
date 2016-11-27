Write-Host "Branch: $env:APPVEYOR_REPO_BRANCH"
Write-Host "Author: $env:APPVEYOR_REPO_COMMIT_AUTHOR"

Describe 'Pester Test' {
    It 'Fails by design' {
        $true | Should Be $false
    }
}
