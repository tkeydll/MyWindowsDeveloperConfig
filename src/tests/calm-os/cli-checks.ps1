$pass = 0; $fail = 0
function Check($label, [scriptblock]$test) {
    try {
        $ok = & $test
    } catch {
        $ok = $false
    }
    if ($ok) { Write-Host "PASS  $label" -ForegroundColor Green; $script:pass++ }
    else      { Write-Host "FAIL  $label" -ForegroundColor Red;   $script:fail++ }
}

# PowerShell 7
Check "pwsh --version starts with 7."             { (pwsh --version 2>$null) -match '^PowerShell 7\.' }

# File Explorer & taskbar
$explorer = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'
Check "Explorer shows the full path in its title bar" { (Get-ItemPropertyValue -LiteralPath "$explorer\CabinetState" -Name FullPath -ErrorAction Stop) -eq 1 }
Check "Quick Access hides frequent folders"           { (Get-ItemPropertyValue -LiteralPath $explorer -Name ShowFrequent -ErrorAction Stop) -eq 0 }
Check "Taskbar End Task is enabled"                   { (Get-ItemPropertyValue -LiteralPath "$explorer\Advanced\TaskbarDeveloperSettings" -Name TaskbarEndTask -ErrorAction Stop) -eq 1 }

# WSL & VM platform
Check "wsl --version succeeds"                    { (wsl --version 2>$null) -ne $null }
Check "vmcompute service registered"              { (Get-Service vmcompute -ErrorAction SilentlyContinue) -ne $null }
Check "wsl lists Ubuntu"                          { (wsl -l -v 2>$null) -match 'Ubuntu' }
Check "wsl lsb_release shows Ubuntu"              { (wsl -- lsb_release -d 2>$null) -match '^Description:\s+Ubuntu' }

# Git
Check "git --version succeeds"                    { (git --version 2>$null) -ne $null }
Check "git resolves under Program Files\Git"      { (where.exe git 2>$null) -match 'C:\\Program Files\\Git' }

# GitHub CLI & Copilot
Check "gh --version succeeds"                     { (gh --version 2>$null) -ne $null }
Check "gh copilot --version succeeds"             { (gh copilot --version 2>$null) -ne $null }

# VS Code
Check "code --version succeeds"                   { (code --version 2>$null) -ne $null }

# Copilot plugins
Check "win-dev-skills marketplace source present" { (copilot plugin marketplace list 2>$null) -match 'win-dev-skills' }
Check "winui plugin listed from win-dev-skills"   { (copilot plugin list 2>$null) -match 'winui' }

Write-Host ""
Write-Host "Results: $pass passed, $fail failed" -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Yellow' })
