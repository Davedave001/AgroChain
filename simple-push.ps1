# Simple script to verify and force push
Write-Host "Verifying commits..." -ForegroundColor Yellow

# Show commit dates
Write-Host "`nCommit dates (first 5):" -ForegroundColor Cyan
git log --format="%ai %s" -5

# Check if we need to force push
Write-Host "`nFetching from remote..." -ForegroundColor Yellow
git fetch origin 2>&1 | Out-Null

$local = git rev-parse HEAD
$remote = git rev-parse origin/main 2>$null

if ($LASTEXITCODE -eq 0 -and $local -eq $remote) {
    Write-Host "`nLocal and remote match, but dates might be different." -ForegroundColor Yellow
    Write-Host "Force pushing anyway to ensure dates are updated..." -ForegroundColor Green
} else {
    Write-Host "`nLocal and remote differ. Force pushing..." -ForegroundColor Green
}

Write-Host "`nForce pushing to origin/main..." -ForegroundColor Yellow
git push -f origin main

Write-Host "`nDone! Wait a few minutes for GitHub to update the contribution graph." -ForegroundColor Green

