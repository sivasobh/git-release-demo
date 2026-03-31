# Git Flow Release Helper Script (Windows PowerShell)
#
# Usage: .\scripts\create-release.ps1 -VersionType patch|minor|major
#
# Example:
#   .\scripts\create-release.ps1 -VersionType patch
#   .\scripts\create-release.ps1 -VersionType minor
#

param(
    [ValidateSet('major', 'minor', 'patch')]
    [string]$VersionType = 'patch'
)

$ErrorActionPreference = 'Stop'

# Colors
$Green = 'Green'
$Yellow = 'Yellow'
$Red = 'Red'

function Write-Status {
    param([string]$Message, [string]$Color = 'White')
    Write-Host $Message -ForegroundColor $Color
}

Write-Status "=== Git Flow Release Helper ===" $Yellow

# Check if we're in a git repository
try {
    git rev-parse --git-dir > $null 2>&1
}
catch {
    Write-Status "Error: Not in a git repository" $Red
    exit 1
}

# Check for uncommitted changes
$changes = git diff-index --quiet HEAD 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Status "Error: You have uncommitted changes. Please commit or stash them first." $Red
    exit 1
}

# Get the latest tag or default to v0.0.0
$currentVersion = git describe --tags --match 'v*.*.*' --abbrev=0 2>$null
if ($null -eq $currentVersion) {
    $currentVersion = 'v0.0.0'
}
Write-Status "✓ Current version: $currentVersion" $Green

# Remove 'v' prefix for processing
$versionNum = $currentVersion -replace '^v'

# Parse version components
$parts = $versionNum -split '\.'
$major = [int]$parts[0]
$minor = [int]$parts[1]
$patch = [int]$parts[2]

# Calculate new version based on input
switch ($VersionType) {
    'major' {
        $newMajor = $major + 1
        $newMinor = 0
        $newPatch = 0
    }
    'minor' {
        $newMajor = $major
        $newMinor = $minor + 1
        $newPatch = 0
    }
    'patch' {
        $newMajor = $major
        $newMinor = $minor
        $newPatch = $patch + 1
    }
}

$newVersion = "v$newMajor.$newMinor.$newPatch"
Write-Status "✓ New version: $newVersion" $Green

# Determine base branch
$baseBranch = 'main'
try {
    git rev-parse --verify "origin/develop" > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        $baseBranch = 'develop'
        Write-Status "✓ Using 'develop' as base branch" $Green
    }
}
catch {
    Write-Status "✓ Using 'main' as base branch" $Green
}

# Create release branch name
$releaseBranch = "release/$newVersion"

# Fetch latest changes
Write-Status "Fetching latest changes..." $Yellow
git fetch origin

# Check if release branch already exists
try {
    git rev-parse --verify "origin/$releaseBranch" > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Status "Error: Release branch '$releaseBranch' already exists" $Red
        exit 1
    }
}
catch {
    # Branch doesn't exist, which is good
}

# Create and checkout release branch
Write-Status "Creating release branch: $releaseBranch" $Yellow
git checkout -b $releaseBranch "origin/$baseBranch"
if ($LASTEXITCODE -ne 0) {
    Write-Status "Error: Failed to create release branch" $Red
    exit 1
}

# Update version files
Write-Status "Updating version files..." $Yellow

$versionUpdated = $false
$versionStr = "$newMajor.$newMinor.$newPatch"

# Update package.json if exists
if (Test-Path 'package.json') {
    $content = Get-Content 'package.json' -Raw
    $content = $content -replace '"version"\s*:\s*"[^"]*"', """version"": ""$versionStr"""
    Set-Content 'package.json' $content
    git add 'package.json'
    $versionUpdated = $true
    Write-Status "✓ Updated package.json" $Green
}

# Update VERSION file if it exists
if (Test-Path 'VERSION') {
    Set-Content 'VERSION' $versionStr
    git add 'VERSION'
    $versionUpdated = $true
    Write-Status "✓ Updated VERSION" $Green
}

# Update setup.py if exists
if (Test-Path 'setup.py') {
    $content = Get-Content 'setup.py' -Raw
    $content = $content -replace 'version\s*=\s*"[^"]*"', """version=""$versionStr"""
    Set-Content 'setup.py' $content
    git add 'setup.py'
    $versionUpdated = $true
    Write-Status "✓ Updated setup.py" $Green
}

# Commit version changes if any files were updated
if ($versionUpdated) {
    git commit -m "chore: bump version to $newVersion"
    Write-Status "✓ Committed version bump" $Green
}

# Push release branch to origin
Write-Status "Pushing release branch to origin..." $Yellow
git push -u origin $releaseBranch
if ($LASTEXITCODE -ne 0) {
    Write-Status "Error: Failed to push release branch" $Red
    exit 1
}
Write-Status "✓ Pushed: $releaseBranch" $Green

Write-Host ""
Write-Status "=== Release Branch Created Successfully ===" $Green
Write-Host ""
Write-Status "Next steps:" $Yellow
Write-Status "  1. Make any release-related changes on: $releaseBranch" 
Write-Status "  2. Trigger the GitHub Actions workflow: Custom Release"
Write-Status "  3. Choose version type: $VersionType"
Write-Status "  4. Merge PRs created by the workflow"
Write-Host ""
Write-Status "Release details:" $Yellow
Write-Status "  Current version: $currentVersion"
Write-Status "  New version: $newVersion"
Write-Status "  Release branch: $releaseBranch"
Write-Status "  Base branch: $baseBranch"
Write-Host ""
