% Caleb Carr 2019 | https://github.com/calebmcarr
% Advanced Radar Research Center | Norman, OK
% This software is licensed under the GPL v3.  All modifications and redistributions must comply.

% data_stream.m returns 32 16-bit binary numbers to be spit into the SPI interface
function data = data_stream(data)
  %returns 32 16-bit (double word) values in the variable 'data'
  %generation is currently random but plan to integrate machine learning
  in_1 = 1;
  in_2 = 16;
  for i = 1:32
    data(in_1:in_2) = randi([0 1],1,16);
    in_1 = in_1 + 16;
    in_2 = in_2 + 16;
  end
