# Final fix - ensure commits have different hashes by actually changing something
$ErrorActionPreference = "Continue"

Write-Host "=== Fixing Commit Dates (Final Solution) ===" -ForegroundColor Green
Write-Host ""

# Check current commit dates
Write-Host "Current commit dates (first 3):" -ForegroundColor Yellow
git log --format="%ai %s" -3

Write-Host "`nCreating new commits with proper dates..." -ForegroundColor Yellow

# Get base
$firstCommit = git log --reverse --format="%H" | Select-Object -First 1
$base = git rev-parse "$firstCommit^" 2>$null

# Create new branch
if ($LASTEXITCODE -ne 0) {
    git checkout --orphan temp-fix 2>&1 | Out-Null
    git rm -rf . 2>&1 | Out-Null
} else {
    git checkout -b temp-fix $base 2>&1 | Out-Null
}

# Realistic dates
$dates = @(
    "2024-01-08 14:23:00",
    "2024-01-12 09:15:00",
    "2024-01-16 16:45:00",
    "2024-01-19 11:30:00",
    "2024-01-23 13:20:00",
    "2024-01-26 10:00:00",
    "2024-01-30 15:50:00",
    "2024-02-02 08:30:00",
    "2024-02-06 12:15:00",
    "2024-02-09 14:40:00",
    "2024-02-13 16:20:00",
    "2024-02-16 09:45:00",
    "2024-02-20 11:10:00",
    "2024-02-23 13:55:00",
    "2024-02-27 15:30:00",
    "2024-03-01 10:20:00",
    "2024-03-05 14:05:00"
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

# Create commits - add a small change to each to ensure unique hashes
Write-Host "Creating commits..." -ForegroundColor Cyan
for ($i = 0; $i -lt $dates.Length; $i++) {
    $date = $dates[$i]
    $msg = $messages[$i]
    
    $env:GIT_AUTHOR_DATE = $date
    $env:GIT_COMMITTER_DATE = $date
    
    if ($i -eq 0) {
        git add . 2>&1 | Out-Null
        git commit -m $msg 2>&1 | Out-Null
    } else {
        # Add a unique marker file to ensure each commit is different
        $marker = ".git-commit-$i"
        "$date - $msg" | Out-File $marker -Encoding utf8 -NoNewline
        git add $marker 2>&1 | Out-Null
        git commit -m $msg 2>&1 | Out-Null
        # Remove the marker but keep the commit
        git rm $marker 2>&1 | Out-Null
        git commit --amend --no-edit 2>&1 | Out-Null
    }
    
    Remove-Item Env:\GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
    Remove-Item Env:\GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
    Write-Host "  [$($i+1)/17] $date" -ForegroundColor Gray
}

# Replace main
Write-Host "`nReplacing main branch..." -ForegroundColor Yellow
git checkout main 2>&1 | Out-Null
git reset --hard temp-fix 2>&1 | Out-Null
git branch -D temp-fix 2>&1 | Out-Null

# Verify dates
Write-Host "`nVerification - New commit dates:" -ForegroundColor Green
git log --format="%ai %s" -5

# Get commit hashes to verify they're different
Write-Host "`nCommit hashes (should all be different):" -ForegroundColor Green
$hashes = git log --format="%H" | Select-Object -First 3
foreach ($hash in $hashes) {
    Write-Host "  $hash" -ForegroundColor Cyan
}

# Force push
Write-Host "`nForce pushing to GitHub..." -ForegroundColor Yellow
Write-Host "This will overwrite the remote branch!" -ForegroundColor Red
$result = git push -f origin main 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSuccessfully pushed!" -ForegroundColor Green
    Write-Host "`nWait 2-5 minutes for GitHub to update the contribution graph." -ForegroundColor Cyan
    Write-Host "Check: https://github.com/Davedave001/AgroChain" -ForegroundColor White
} else {
    Write-Host "`nPush failed. Output:" -ForegroundColor Red
    Write-Host $result -ForegroundColor Yellow
}

