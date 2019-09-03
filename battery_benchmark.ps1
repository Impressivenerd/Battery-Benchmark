####
# Battery Benchmark
# Written By: Jeff Patyk
# Usage: powershell .\battery_benchmark.ps1
# GitHub: https://github.com/Impressivenerd/Battery-Benchmark
# License: MIT
####

$path = Read-Host -Prompt "Input a filename"
while(1) {
      # If the path does not exist, start by adding the header row
      if(-Not (Test-Path $path)) {
            Add-Content $path "FullChargeCapacity,DesignedCapacity,EstimatedRemainingCapacity,EstimatedChargeRemaining,Timestamp"
      }

      $strComputer = "LocalHost" 

      # Get the full charge capacity and write it out to the console
      $fullChargeCapacity = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity
      write-host "Full Charged Capacity: " $fullChargeCapacity

      # Get the designed capacity of the battery and write it out the console
      $designedCapacity = (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI").DesignedCapacity
      write-host "Designed Capacity: " $designedCapacity

      # Get all objects as reported by the Win32_Battery class
      $colItems = get-wmiobject -class "Win32_Battery" -namespace "root\CIMV2" -computername $strComputer 

      # Get the current Timestamp
      $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

      # Generate the Record to output to the file
      $outputLine = "$fullChargeCapacity,$designedCapacity,$($colItems.EstimatedChargeRemaining / 100 * $designedCapacity),$($colItems.EstimatedChargeRemaining),$ts"
      Add-Content $path $outputLine

      # Write out the recorded information to the console
      write-host $outputLine

      # Wait 60 Seconds before the next battery poll
      Start-Sleep -Seconds 60 
}