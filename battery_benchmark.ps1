####
# Battery Benchmark
# Written By: Jeff Patyk
# Usage: powershell .\battery_benchmark.ps1
# GitHub: https://github.com/Impressivenerd/Battery-Benchmark
# License: MIT
####

param (
    # Write details only to the console. Do not write anything to a file
    [Switch]
    $ReadOnly,
    
    # Write contents to a file, whose path is specified by -output
    [String]
    $Output,

    # Override Polling Period
    [Int]
    $PollingFrequency = 60
)

# If no path was set, prompt for one. If ReadOnly was specified, output a message indicating this is the case
if(!$ReadOnly) {
    if($Output -eq $NULL -Or $Output -eq ""){
        $Output = Read-Host -Prompt "Input a filename"

        if($Output -eq "") {
            # Since no path was specified, assuming ReadOnly
            $ReadOnly = $TRUE;
            Write-Host "Warning! No output path was specified, assuming ReadOnly mode." -ForegroundColor Red
        }
    }
} else {
    Write-Host "ReadOnly Mode Active! No values are being recorded." -ForegroundColor Green
}

# Sanity Check to make sure we don't try polling any faster than once per second
if($PollingFrequency -lt 1){
    $PollingFrequency = 1;
    Write-Host "Warning! Invalid PollingFrequency detected. Now polling at once per second." -ForegroundColor Red
}

# Main Loop
while(1) {
      if(!$ReadOnly){
          # If the path does not exist, start by adding the header row
          if(-Not (Test-Path $Output)) {
              Add-Content $Output "DesignedCapacity,FullChargeCapacity,EstimatedRemainingCapacity,BatteryStatus,EstimatedChargeRemaining,Timestamp"
          }
      }

      $strComputer = "LocalHost" 

      # Get the full charge capacity and write it out to the console
      $fullChargeCapacity = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity

      # Get the designed capacity of the battery and write it out the console
      $designedCapacity = (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI").DesignedCapacity

      # Get On Battery / AC Status
      $onPowerLine = (Get-WmiObject -class "BatteryStatus" -namespace "ROOT\WMI").PowerOnLine
      $batteryStatus = $( If ($onPowerLine -eq $TRUE ) { "AC" } else { "Battery"} )

      # Get all objects as reported by the Win32_Battery class
      $colItems = Get-WmiObject -Class "Win32_Battery" -Namespace "ROOT\CIMV2" -ComputerName $strComputer

      # Get the current Timestamp
      $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

      # Generate the Record to output to the file
      $outputLine = "$designedCapacity,$fullChargeCapacity,$($colItems.EstimatedChargeRemaining / 100 * $designedCapacity),$batteryStatus,$($colItems.EstimatedChargeRemaining),$ts"
      if(!$ReadOnly) {
          Add-Content $Output $outputLine
      }

      # Write out the recorded information to the console
      $outputRecord = new-object psobject
      $outputRecord | add-member -NotePropertyName "Designed Capacity" -NotePropertyValue $designedCapacity
      $outputRecord | add-member -NotePropertyName "Full Charge Capacity" -NotePropertyValue $fullChargeCapacity
      $outputRecord | add-member -NotePropertyName "Remaining Capacity" -NotePropertyValue $($colItems.EstimatedChargeRemaining / 100 * $designedCapacity)
      $outputRecord | add-member -NotePropertyName "Remaining Charge" -NotePropertyValue $($colItems.EstimatedChargeRemaining)
      $outputRecord | add-member -NotePropertyName "Battery Status" -NotePropertyValue $batteryStatus
      $outputRecord | add-member -NotePropertyName "Time" -NotePropertyValue $ts
      if($outputRecordHeaders -eq $NULL) {
          ($outputRecord | ft | Out-String).TrimEnd()
          $outputRecordHeaders = $TRUE
      } else {
          ($outputRecord | ft -HideTableHeaders | Out-String).Replace("`r`n", '')
      }


      # Wait 60 Seconds before the next battery poll
      Start-Sleep -Seconds $PollingFrequency
}