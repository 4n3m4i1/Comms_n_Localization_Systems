# QAM-16 Sub-Sea Ultrasonic Communications
A sample for low datarate high bandwidth efficiency QAM.  
Target: iCE40 UP5k via icestorm and nextpnr.  
PGL Sandpiper v1 Dev Board used  
  
## RX / Demodulation
Each symbol transmits 4 bits of information.
As such a constellation consists of:
```
0   1   2   3
4   5   6   7
8   9   10  11
12  13  14  15
```  
This is done by splitting any arbitrary 4 bit value into:
-`0bAB`
-`0bCD`
  
The 2 bit symbols are then further changed into Q16 scalars for multiplication with the in phase and quadrature LO signals. This is all handled in the digital domain. Two SBMAC16 instances setup as 16x16 multipliers that exclusively handle this multiplication.  
A standard NCO driven LUT provides the sin and cos waveform data, this NCO offers phase advance and delay inputs that allow alignment of the LO to the incoming carrier, creating a coherent demodulation scheme.  

## Pilot Symbols and Packet Structure
To ensure coherency pilot symbols are transmitted on each packet sent that are real-time decoded, offering a perspective on how rotated the constellation is. By advancing and delaying the LO phase this constellation offset can be corrected. Once this correction has been applied the data reception and decode phase should continue without issue.  
  
The TX/RX packet structure is as follows:
[2-4 symbols Pilot] [16 symbols data] [2-4 symbols termination]
  

