fwcmd="/sbin/ipfw"
internet="em0"
local="el0"
#ipinet="1.1.1.1"
iplocal="10.10.0.1"
netlocal="10.10..0/24"

${fwcmd} -f flush
${fwcmd} add check-state
${fwcmd} add allow ip from any to any via lo0
${fwcmd} add allow udp from any to me 53 
${fwcmd} add allow tcp from any to any established
${fwcmd} add allow udp from any to any established

${fwcmd} add deny ip from any to 127.0.0.0/8
${fwcmd} add deny ip from 127.0.0.0/8 to any

${fwcmd} add allow ip from ${netlocal} to any via ${local}
${fwcmd} add allow ip from any to ${netlocal} via ${local}

${fwcmd} nat 1 config ip ${ipinet} reset same_ports deny_in redirect_port tcp ${ipinet}:3300 3300 redirect_port tcp 10.1:3300 3389

${fwcmd} add nat 1 tcp from any to any via ${internet}
${fwcmd} add nat 1 udp from any to any via ${internet}
${fwcmd} add nat 1 icmp from any to any icmptypes 0,8 via ${internet}
