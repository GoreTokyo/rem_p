
# Get printers and ports
$printers = Get-Printer
$ports = Get-PrinterPort

# Combine printer and port info
$printerList = $printers | ForEach-Object {
    $port = $ports | Where-Object { $_.Name -eq $_.PortName }
    [PSCustomObject]@{
        No          = $null
        PrinterName = $_.Name
        DriverName  = $_.DriverName
        PortName    = $_.PortName
        IPAddress   = $port.PrinterHostAddress
    }
}

# Add numbering
$counter = 1
$printerList | ForEach-Object { $_.No = $counter; $counter++ }

# Display list
Write-Host "Current Printer List"
$printerList | Format-Table No, PrinterName, DriverName, PortName, IPAddress -AutoSize

# Input for deletion
Write-Host ""
$inputNumbers = Read-Host "Enter printer numbers to delete separated by commas (e.g. 1,3,5)"

# Convert input to number array
$numbersToDelete = $inputNumbers -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }

if ($numbersToDelete.Count -eq 0) {
    Write-Host "No valid numbers entered. Exiting."
    return
}

# Get selected printer names
$targets = $printerList | Where-Object { $numbersToDelete -contains $_.No } | Select-Object -ExpandProperty PrinterName

if ($targets.Count -eq 0) {
    Write-Host "No matching printers found."
    return
}

# Confirmation
Write-Host ""
Write-Host "The following printers will be deleted:"
$targets | ForEach-Object { Write-Host $_ }

$confirm = Read-Host "Proceed with deletion? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Canceled."
    return
}

# Delete selected printers
foreach ($printer in $targets) {
    try {
        Remove-Printer -Name $printer -ErrorAction Stop
        Write-Host "Deleted: $printer"
    } catch {
        Write-Host "Failed to delete: $printer"
    }
}

Write-Host ""
Write-Host "Process completed."
