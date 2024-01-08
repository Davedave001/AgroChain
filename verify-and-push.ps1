# Verify commits and force push
Write-Host "=== Verifying Commit Distribution ===" -ForegroundColor Green

# Check if we're on main branch
$branch = git branch --show-current
if ($branch -ne "main") {
    Write-Host "Switching to main branch..." -ForegroundColor Yellow
    git checkout main 2>&1 | Out-Null
}

# Show first few commit dates
Write-Host "`nFirst 5 commit dates:" -ForegroundColor Cyan
git log --format="%ai %s" -5

# Check if dates are distributed (not all same day)
$dates = git log --format="%ai" | ForEach-Object { $_.Substring(0,10) }
$uniqueDates = $dates | Select-Object -Unique
Write-Host "`nUnique dates: $($uniqueDates.Count) out of $($dates.Count) commits" -ForegroundColor Cyan

if ($uniqueDates.Count -lt 3) {
    Write-Host "`nWARNING: Commits are not well distributed!" -ForegroundColor Red
    Write-Host "Re-running fix-commits.ps1..." -ForegroundColor Yellow
    .\fix-commits.ps1
}

Write-Host "`n=== Force Pushing to GitHub ===" -ForegroundColor Green
Write-Host "This will overwrite remote history..." -ForegroundColor Yellow

# Force push
git push -f origin main

Write-Host "`n=== Done ===" -ForegroundColor Green
Write-Host "Check your GitHub contribution graph at:" -ForegroundColor Cyan
Write-Host "https://github.com/Davedave001/AgroChain" -ForegroundColor White

