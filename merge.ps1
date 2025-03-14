function Show-Welcome {
    Clear-Host
    Write-Host "----------------------------------" -ForegroundColor Cyan
    Write-Host "       CleanRip ISO Merger        " -ForegroundColor Cyan
    Write-Host "----------------------------------" -ForegroundColor Cyan
    Write-Host "Copyright 2025 Robin91862" -ForegroundColor Yellow
    Write-Host "https://github.com/Robin91862/CleanRip-ISO-Merger" -ForegroundColor Yellow
    Write-Host "Licensed under the Apache License, Version 2.0" -ForegroundColor Yellow
    Write-Host "Make sure this script is in the same folder as your ISO files!" -ForegroundColor Red
}

function Test-Hash {
    param (
        [string]$filePath,
        [string]$expectedHash
    )
    
    $hash = Get-FileHash -Path $filePath -Algorithm MD5
    return $hash.Hash -eq $expectedHash
}

function Remove-PartFiles {
    param (
        [string]$baseFileName
    )
    Remove-Item "$baseFileName.part*" -Force
    Write-Host "Cleaned up part files." -ForegroundColor Green
}

Show-Welcome

$expectedHash = Read-Host "Enter the expected MD5 hash of the output ISO"

$baseFileName = Read-Host "Enter the game ID (it's the ID before .part0.iso)"

Write-Host "You entered:" -ForegroundColor Cyan
Write-Host "Expected MD5 Hash: $expectedHash" -ForegroundColor Yellow
Write-Host "Game ID: $baseFileName" -ForegroundColor Yellow

$confirmation = Read-Host "Is this information correct? (Y/N)"
if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
    Read-Host "Press Enter to exit"
    exit
}

$mergeConfirmation = Read-Host "Do you want to merge these files? (Y/N)"
if ($mergeConfirmation -ne 'Y' -and $mergeConfirmation -ne 'y') {
    Read-Host "Press Enter to exit"
    exit
}

$command = "copy /b $baseFileName.part?.iso $baseFileName.iso > NUL 2>&1"

Write-Host "Executing command, please wait!" -ForegroundColor Green
Start-Process cmd.exe -ArgumentList "/c", $command -NoNewWindow -Wait

$outputFileName = "$baseFileName.iso"

if (Test-Path $outputFileName) {
    if (Test-Hash -filePath $outputFileName -expectedHash $expectedHash) {
        Write-Host "MD5 hash verification successful. The output file is valid." -ForegroundColor Green
        
        $cleanupConfirmation = Read-Host "Do you want to delete the part files? (Y/N)"
        if ($cleanupConfirmation -eq 'Y' -or $cleanupConfirmation -eq 'y') {
            $finalConfirmation = Read-Host "Are you sure you want to delete the part files? (Y/N)"
            if ($finalConfirmation -eq 'Y' -or $finalConfirmation -eq 'y') {
                Remove-PartFiles -baseFileName $baseFileName
                Read-Host "Press Enter to exit"
            } else {
                Write-Host "Cleanup skipped." -ForegroundColor Yellow
                Read-Host "Press Enter to exit"
            }
        } else {
            Write-Host "Cleanup skipped." -ForegroundColor Yellow
            Read-Host "Press Enter to exit"
        }
    } else {
        Write-Host "MD5 hash verification failed. The output file may be corrupted." -ForegroundColor Red
        Read-Host "Press Enter to exit"
    }
} else {
    Write-Host "Output file '$outputFileName' was not created." -ForegroundColor Red
    Read-Host "Press Enter to exit"
}
