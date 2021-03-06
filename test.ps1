## PowerShell in Practice
## by Richard Siddaway
## Listing A.1
## Using Add-Type to create a class
##  Creates an IP Route Table 
#################################
function Get-RouteTable {
param (
    [parameter(ValueFromPipeline=$true)]  
    [string]$computer="."
)

## create class for object
$source=@"                                 
public class WmiIPRoute
{
    public  string Destination  {get; set;}
    public  string Mask    {get; set;}
    public  string NextHop {get; set;}
    public  string Interface {get; set;}
    public  int Metric  {get; set;}
}
"@
Add-Type -TypeDefinition $source -Language CSharpversion3

    $data = @()
    Get-WmiObject -Class Win32_IP4RouteTable -ComputerName $computer|
     foreach {
        $route = New-Object -TypeName WmiIPRoute -Property @{
            Destination = $_.Destination
            Mask        = $_.Mask
            NextHop     = $_.NextHop
            Metric      = $_.Metric1
        }    

        $filt = "InterfaceIndex='" + $_.InterfaceIndex + "'"  
        $ip = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration 
              -Filter $filt -ComputerName $computer).IPAddress

        if ($_.InterfaceIndex -eq 1) {$route.Interface = "127.0.0.1"}
        elseif ($ip.length -eq 2){$route.Interface = $ip[0]}
        else {$route.Interface = $ip}
        
        $data += $route
    }
    $data | Format-Table -AutoSize 
}
