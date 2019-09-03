# Battery-Benchmark
A simple powershell script which will log the battery percentage over time. For use with benchmarking performance / battery life.

# Getting Started
## Allowing PowerShell Script Execution
You may have to enable PowerShell Script execution before this script will run. To do so, open up a PowerShell command prompt as Administrator and type in the following:

```
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
```

This will allow any PowerShell script to run during the current process only. If you want to read up more about the different ways to set your execution policy (such as by modifying group policy or by setting the policy gloablly), I recommend you read up on the command on Microsofts website at: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-6

## Executing The Script
To execute the script, simply open a PowerShell prompt and execute the script:

```
powershell .\battery_benchmark.ps1
```

Once executed, the script will prompt for a Filename. This filename should be the path you want your CSV files saved to. This could be the full path, or a relative path to the script.

Once the script begins running, your batteries information will be polled every one minute, looking at the following details:
* FullChargeCapacity
* DeisgnedCapacity
* EstimatedRemainingCapacity
* EstimatedChargeRemaining
* Timestamp

If the file does not exist, a new one will be created using the name you provided. If the file already exists, it will append a new record each time the battery is polled.

## How To Use
The original intention of this script was to test battery life during various discharging / recharging scnearios. Once this script is ran, let it run in the background while performing whatever tests need to be completed on the computer. Once those tests are completed, close your powershell prompt and look at the CSV file created using your spreadsheet editor of choice. The stats recorded in the file can allow you to graph the batteries percentage over time, as well as length of time from start to finish. 

# Notes
* The EstimatedRemainingCapacity field is a calculated field by using the total capacity of the battery and the percentage. So far, so I have been able to find an actual variable that holds the live, up to date capacity of the battery.
* Sometimes, strange percentages are reported when on AC if at 100%. Example: Dell Precision 5520 reports 114% when plugged in and at 100% capacity.