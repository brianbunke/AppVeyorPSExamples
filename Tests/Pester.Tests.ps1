Describe 'Unit Test' -Tag 'unit' {
    It 'Compares $true to itself' {
        $true | Should Be $true
    }
}

Describe 'Integration Test' -Tag 'integration' {
    It 'Checks the current time via timeapi.org' {
        $Now = ([DateTime](Invoke-RestMethod -Uri 'http://www.timeapi.org/utc/now' -Method Get)).ToUniversalTime()
        $Now | Should Not BeNullOrEmpty
        $Now | Should BeLessThan (Get-Date).ToUniversalTime()
        $Now | Should BeGreaterThan (Get-Date).ToUniversalTime().AddSeconds(-10)
    }
}
