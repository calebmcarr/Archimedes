% Caleb Carr | 2019
% Advanced Radar Research Center, Norman, OK
% This software is licensed under the GPL v.3.  All modifications and distributions must comply.

% single_varactor.m controls the tuning of a single varactors
try
  S = spi('aardvark',0,0);
  connect(S);
catch
  %if fn errored out earlier, necessary to disconnect and reconnect.
  disconnect(S);
  clear('S');
  S = spi('aardvark',0,0);
  connect(S);
end
% initialize SPI parameters
% M tells the eval board what mode to function in. [1 1] writes to data registers.
M = [1 1];
% address is a six bit value to control which Vout to send to DEC: 0-39; BIN: 000000 - 100111
address_prompt = 'Output voltage address: ';
% output voltage is a 16-bit DAC voltage.  0000000000000000 = 0V; 1111111111111111 = 36V
% Vout = 4(Vref)(DAC_CODE/2^16) where Vref = 3V
DAC_CODE_prompt = 'Output voltage: ';
cont_prompt = 'Continue (Y/N): ';
cont = 'Y';
while cont == 'Y'
  % Continually update the varactor output as long as user wishes to.
  % enter a decimal number for both ADDRESS and DAC_CODE.  Will convert to binary array.
  ADDRESS = input(address_prompt);
  DAC_CODE = input(DAC_CODE_prompt);
  ADDRESS = de2bi(ADDRESS,6,'left-msb');
  DAC_CODE = de2bi(DAC_CODE,16,'left-msb');
  DATA = [M ADDRESS DAC_CODE];
  write(S,DATA);
  cont = input(cont_prompt,'s');
end
disconnect(S);
clear('S');
