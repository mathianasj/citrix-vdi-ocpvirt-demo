Install-WindowsFeature DHCP -IncludeManagementTools
Set-NetIPAddress -IPAddress 192.168.1.2 -InterfaceAlias "Ethernet 2" -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses 192.168.1.2
netsh dhcp add securitygroups
Restart-Service dhcpserver
Add-DhcpServerInDC -IPAddress 192.168.1.2
Add-DhcpServerv4Scope -name "Corpnet" -StartRange 192.168.1.10 -EndRange 192.168.1.254 -SubnetMask 255.255.255.0 -State Active
Set-DhcpServerv4OptionValue -OptionID 3 -Value 192.168.1.1 -ScopeID 192.168.1.0
Set-DhcpServerv4OptionValue -DnsDomain win.pm874.sandbox2129.opentlc.com -DnsServer 192.168.1.2

Install-WindowsFeature AD-Domain-Services
$secure = convertto-securestring "TestPa$$word" -asplaintext -force
Install-ADDSForest -DomainName "win.pm874.sandbox2129.opentlc.com" -SafeModeAdministratorPassword $secure