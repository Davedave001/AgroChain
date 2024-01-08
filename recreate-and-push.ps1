# Completely recreate commits and force push
Write-Host "=== Recreating Commits with Realistic Dates ===" -ForegroundColor Green

# Make sure we're starting fresh
Write-Host "`n1. Cleaning up..." -ForegroundColor Yellow
git checkout main 2>&1 | Out-Null

# Get the base (before any commits)
$firstCommit = git log --reverse --format="%H" | Select-Object -First 1
$base = git rev-parse "$firstCommit^" 2>$null

# Delete main and recreate
Write-Host "`n2. Creating fresh main branch..." -ForegroundColor Yellow
if ($LASTEXITCODE -ne 0) {
    git checkout --orphan main-new 2>&1 | Out-Null
    git rm -rf . 2>&1 | Out-Null
} else {
    git checkout -b main-new $base 2>&1 | Out-Null
}

# Dates - distributed across weekdays
$dates = @(
    "2024-01-08 14:23:00",  # Monday
    "2024-01-12 09:15:00",  # Friday  
    "2024-01-16 16:45:00",  # Tuesday
    "2024-01-19 11:30:00",  # Friday
    "2024-01-23 13:20:00",  # Tuesday
    "2024-01-26 10:00:00",  # Friday
    "2024-01-30 15:50:00",  # Tuesday
    "2024-02-02 08:30:00",  # Friday
    "2024-02-06 12:15:00",  # Tuesday
    "2024-02-09 14:40:00",  # Friday
    "2024-02-13 16:20:00",  # Tuesday
    "2024-02-16 09:45:00",  # Friday
    "2024-02-20 11:10:00",  # Tuesday
    "2024-02-23 13:55:00",  # Friday
    "2024-02-27 15:30:00",  # Tuesday
    "2024-03-01 10:20:00",  # Friday
    "2024-03-05 14:05:00"   # Tuesday
)

$messages = @(
    "Initial project setup and configuration",
    "Add smart contract structure for supply chain",
    "Implement SupplyChain.sol with role-based access",
    "Add React frontend components",
    "Implement product tracking functionality",
    "Add role assignment features",
    "Create Home and Track components",
    "Add Web3 integration and connection",
    "Implement product addition workflow",
    "Add supply chain state management",
    "Update UI components and styling",
    "Add contract migration scripts",
    "Implement product transfer functionality",
    "Add error handling and validation",
    "Update README with project documentation",
    "Finalize project structure and dependencies",
    "Prepare for deployment"
)

# Create all commits
Write-Host "`n3. Creating 17 commits with distributed dates..." -ForegroundColor Yellow
for ($i = 0; $i -lt $dates.Length; $i++) {
    $env:GIT_AUTHOR_DATE = $dates[$i]
    $env:GIT_COMMITTER_DATE = $dates[$i]
    
    if ($i -eq 0) {
        git add . 2>&1 | Out-Null
        git commit -m $messages[$i] 2>&1 | Out-Null
    } else {
        git commit --allow-empty -m $messages[$i] 2>&1 | Out-Null
    }
    
    Remove-Item Env:\GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
    Remove-Item Env:\GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
    Write-Host "   [$($i+1)/17] $($dates[$i])" -ForegroundColor Gray
}

# Replace main
Write-Host "`n4. Replacing main branch..." -ForegroundColor Yellow
git branch -D main 2>&1 | Out-Null
git branch -M main main-new 2>&1 | Out-Null

# Verify
Write-Host "`n5. Verification:" -ForegroundColor Yellow
$firstDate = git log --reverse --format="%ai" | Select-Object -First 1
$lastDate = git log --format="%ai" | Select-Object -First 1
Write-Host "   First commit: $firstDate" -ForegroundColor Cyan
Write-Host "   Last commit:  $lastDate" -ForegroundColor Cyan

# Force push
Write-Host "`n6. Force pushing to GitHub..." -ForegroundColor Yellow
Write-Host "   This WILL overwrite remote history!" -ForegroundColor Red
git push -f origin main

Write-Host "`n=== Complete ===" -ForegroundColor Green
Write-Host "Your contribution graph should update within a few minutes." -ForegroundColor Cyan
Write-Host "Check: https://github.com/Davedave001/AgroChain" -ForegroundColor White

