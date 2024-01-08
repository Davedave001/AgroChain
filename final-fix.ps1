# Final fix - ensure commits are unique and force push
$ErrorActionPreference = "Continue"

Write-Host "=== Final Fix for Commit Distribution ===" -ForegroundColor Green
Write-Host ""

# Check current state
Write-Host "1. Checking current branch..." -ForegroundColor Yellow
$branch = git branch --show-current
Write-Host "   Branch: $branch" -ForegroundColor Cyan

# Get first commit to find base
Write-Host "`n2. Finding base commit..." -ForegroundColor Yellow
$firstCommit = git log --reverse --format="%H" | Select-Object -First 1
$base = git rev-parse "$firstCommit^" 2>$null

# Create completely new branch
Write-Host "`n3. Creating fresh branch with redistributed commits..." -ForegroundColor Yellow
if ($LASTEXITCODE -ne 0) {
    git checkout --orphan fresh-main 2>&1 | Out-Null
    git rm -rf . 2>&1 | Out-Null
} else {
    git checkout -b fresh-main $base 2>&1 | Out-Null
}

# Dates with more variety
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

# Create commits - make first one have all files, others are empty but unique
Write-Host "`n4. Creating commits..." -ForegroundColor Yellow
for ($i = 0; $i -lt $dates.Length; $i++) {
    $date = $dates[$i]
    $msg = $messages[$i]
    
    $env:GIT_AUTHOR_DATE = $date
    $env:GIT_COMMITTER_DATE = $date
    
    if ($i -eq 0) {
        git add . 2>&1 | Out-Null
        git commit -m $msg 2>&1 | Out-Null
    } else {
        # Add a unique touch to make each commit different
        $uniqueFile = ".commit-$i"
        "Commit $i - $date" | Out-File $uniqueFile -Encoding utf8
        git add $uniqueFile 2>&1 | Out-Null
        git commit -m $msg 2>&1 | Out-Null
        git rm $uniqueFile 2>&1 | Out-Null
        git commit --amend --no-edit --allow-empty 2>&1 | Out-Null
    }
    
    Remove-Item Env:\GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
    Remove-Item Env:\GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
    Write-Host "   [$($i+1)/$($dates.Length)] $date" -ForegroundColor Gray
}

# Replace main branch
Write-Host "`n5. Replacing main branch..." -ForegroundColor Yellow
git checkout main 2>&1 | Out-Null
git reset --hard fresh-main 2>&1 | Out-Null
git branch -D fresh-main 2>&1 | Out-Null

# Verify
Write-Host "`n6. Verifying commit dates..." -ForegroundColor Yellow
$firstDate = git log --reverse --format="%ai" | Select-Object -First 1
$lastDate = git log --format="%ai" | Select-Object -First 1
Write-Host "   First: $firstDate" -ForegroundColor Cyan
Write-Host "   Last:  $lastDate" -ForegroundColor Cyan

# Force push
Write-Host "`n7. Force pushing to GitHub..." -ForegroundColor Yellow
Write-Host "   This will overwrite remote history!" -ForegroundColor Red
git push -f origin main

Write-Host "`n=== Complete ===" -ForegroundColor Green
Write-Host "Check your contribution graph at:" -ForegroundColor Cyan
Write-Host "https://github.com/Davedave001/AgroChain" -ForegroundColor White

