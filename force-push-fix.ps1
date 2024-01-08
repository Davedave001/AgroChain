# Force push with proper verification
$ErrorActionPreference = "Continue"

Write-Host "Checking current branch..." -ForegroundColor Yellow
$currentBranch = git branch --show-current
Write-Host "Current branch: $currentBranch" -ForegroundColor Cyan

Write-Host "`nChecking commit dates..." -ForegroundColor Yellow
$commits = git log --format="%ai|%s" | Select-Object -First 3
foreach ($commit in $commits) {
    Write-Host "  $commit" -ForegroundColor Gray
}

Write-Host "`nChecking remote status..." -ForegroundColor Yellow
git fetch origin 2>&1 | Out-Null
$localHash = git rev-parse HEAD
$remoteHash = git rev-parse origin/main 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "Local HEAD:  $localHash" -ForegroundColor Cyan
    Write-Host "Remote HEAD: $remoteHash" -ForegroundColor Cyan
    
    if ($localHash -eq $remoteHash) {
        Write-Host "`nWARNING: Local and remote are the same!" -ForegroundColor Red
        Write-Host "The commits may not have been properly redistributed." -ForegroundColor Yellow
        Write-Host "`nLet's verify the commit dates are correct..." -ForegroundColor Yellow
        
        $firstDate = git log --reverse --format="%ai" | Select-Object -First 1
        Write-Host "First commit date: $firstDate" -ForegroundColor Cyan
        
        if ($firstDate -like "2024-01-08*") {
            Write-Host "`nDates look correct. Trying to force push anyway..." -ForegroundColor Green
            Write-Host "`nForce pushing to origin/main..." -ForegroundColor Yellow
            git push -f origin main 2>&1
        } else {
            Write-Host "`nDates don't match expected values. Re-running redistribution..." -ForegroundColor Red
            Write-Host "Please run .\fix-commits.ps1 again" -ForegroundColor Yellow
        }
    } else {
        Write-Host "`nLocal and remote differ. Force pushing..." -ForegroundColor Green
        git push -f origin main 2>&1
    }
} else {
    Write-Host "Remote branch doesn't exist or can't be accessed." -ForegroundColor Yellow
    Write-Host "Pushing for the first time..." -ForegroundColor Green
    git push -u origin main 2>&1
}

Write-Host "`nDone! Check your GitHub contribution graph." -ForegroundColor Green

