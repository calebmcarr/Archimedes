% Caleb Carr 2019 | https://github.com/calebmcarr
% Advanced Radar Research Center | Norman, OK
% This software is licensed under the GPL v3.  All modifications and redistributions must comply.

% interface.m is the main driver to output 32 16-bit voltages to control varactors
% Initialize the SPI object and connect.
S = spi('aardvark',0,0);
connect(S);
% Intialize location of DATA.txt and line comments
fileID = './DATA.txt'
lineOne = 'Transmitted Voltages: ';
lineTwo = 'V1- Voltages at Each Array: ';
lineThree = 'Varactor Phases: ';
% For the time being, data creation, transmission, and transcription occurs
% on an infinite loop.
while 1
  % Initialize data stream array
  data = ones(16,32);
  data = data_stream(data)
  % Read and write to and from the aardvark
  MOSI = write(S,data);
  % Will return 32*16-bit = 32*2bytes = 64 bytes of data at each step
  %bytesOfData = 64;
  %MISO = read(S,bytesOfData);
  % TODO add ability to read V1- going into receiver.
  % Need this to determine if a null is being placed.

  % TODO add phase calculation.  Need this from Robin.

  % Write Transmitted Voltages data to text file DATA.txt
  fprintf(fileId,lineOne);
  in_1 = 1;
  in_2 = 16;
  for i = 1:32
    % Eventually needs to be corrected for amplified voltage
    fprintf(fileID,'%f ',data(in_1:in_2));
    in_1 = in_1 + 16;
    in_2 = in_2 + 16;
  end
  fprintf(fileID,'\n');
end
