function Send-ZebraPOR {
    <#
    .SYNOPSIS
        Sends a Power On Reset (POR) command to one or more Zebra printers.
 
    .DESCRIPTION
        Connects to Zebra printers over TCP port 9100 and sends the ZPL ~JR
        Power On Reset command, rebooting the printer as if power-cycled.
 
    .PARAMETER IpAddress
        One or more printer IP addresses. Accepts pipeline input.
 
    .PARAMETER Port
        TCP port to connect on. Defaults to 9100.
 
    .EXAMPLE
        Send-ZebraPOR 192.168.1.50
 
    .EXAMPLE
        Send-ZebraPOR 192.168.1.50, 192.168.1.51, 192.168.1.52
 
    .EXAMPLE
        "192.168.1.50", "192.168.1.51" | Send-ZebraPOR
    #>
 
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$IpAddress,
 
        [Parameter()]
        [int]$Port = 9100
    )
 
    process {
        foreach ($ip in $IpAddress) {
            $tcpClient = $null
            $stream    = $null
            try {
                $tcpClient = New-Object System.Net.Sockets.TcpClient
                $tcpClient.Connect($ip, $Port)
                $stream  = $tcpClient.GetStream()
                $bytes   = [System.Text.Encoding]::ASCII.GetBytes("~JR`r`n")
                $stream.Write($bytes, 0, $bytes.Length)
                $stream.Flush()
                Write-Host "[$ip] POR command sent successfully." -ForegroundColor Green
            }
            catch {
                Write-Host "[$ip] Failed: $_" -ForegroundColor Red
            }
            finally {
                if ($stream)    { $stream.Close() }
                if ($tcpClient) { $tcpClient.Close() }
            }
        }
    }
}
