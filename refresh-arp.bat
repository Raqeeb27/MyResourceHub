@echo off
echo Flushing ARP cache...
netsh interface ip delete arpcache

echo.
echo Scanning network 192.168.29.0/24 to repopulate ARP table...
for /l %%i in (1,1,254) do (
    ping -n 1 -w 100 192.168.29.%%i > nul
)

echo.
echo Updated ARP table:
arp -a
pause

