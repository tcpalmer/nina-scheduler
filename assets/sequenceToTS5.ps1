
# Powershell script to migrate NINA sequence files to TS5.  Basically just fixing the
# namespace of TS instructions and renaming one of the custom event containers.

[CmdletBinding()]
param(
    [Parameter(Mandatory, HelpMessage="Path to the initial sequence JSON file")]
    [string]$file,
    [Parameter(Mandatory, HelpMessage="Path to the repaired sequence JSON file")]
    [string]$out
)

if (Test-Path -Path $out) {
    Write-Output "`r`nError: output file exists, will not overwrite: $out`r`n"
    Exit
}

if (Test-Path -Path $file) {
    $raw = Get-Content -Path $file -Raw
    $raw = $raw -replace "Assistant.NINAPlugin", "NINA.Plugin.TargetScheduler"

    Write-Output $raw | Out-File -FilePath $out
    Write-Output "`r`nmigrated to TS5: $file`r`n"
} else {
    Write-Output "`r`nError: input sequence file does not exist`r`n"
}