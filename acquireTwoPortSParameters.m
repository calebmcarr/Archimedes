function [frequencies S] = acquireTwoPortSParameters
%% Baseband Equivalent Modeling of a Transmission Line

% In this example, you model an RF transmission line stimulated by a pulse
% and plot the baseband-equivalent model that the blockset uses to simulate
% the transmission line in the time domain. This example helps you 
% understand how to best apply the baseband-equivalent modeling paradigm of
% performing time-domain simulation using a limited band of frequency data.
% This demo uses SCPI commands to interface with a PNA Series Network
% Analyzer (from Agilent). It is assumed that:
%
% 1. Calibration of the PNA has been completed by the user.
% 2. The Agilent IO libraries have been installed. 
% 
% Author: Siddhartha Shankar

%% Demo Requirements
%
% This demonstration requires the following products:
%
%    * MATLAB       
%    * Instrument Control Toolbox
%
% The Following products are required to utilize the optional sections of
% this demo:
%
%   * Simulink
%   * RF Toolbox
%   * RF Blockset
%% Additional Notes
%
% * This M-File was last used and tested with MATLAB 7.6 (R2008a)
% * Consider using the MATLAB Report Generator to create a report from this
%   M-File
format long;
oldObjects=instrfind;
if ~isempty(oldObjects)
    delete(oldObjects);
    clear oldObjects;
end
resourceStruct = instrhwinfo('visa','agilent'); %#ok<NASGU>
% A generalized way to create a visa interface object:
% eval(['visaObj = ',res.ObjectConstructorName{1}]);
% Caleb - changed sample to GPIB0
visaObj = visa('agilent','GPIB0::16::INSTR');
fprintf("Successfully connected to Agilent PNA\n");
% NOTE: Change GPIB0::16::INSTR appropriately for your PNA configuration

%% Configure interface object
% Set a sufficiently large input buffer size to store the S-Parameter data
set(visaObj, 'InputBufferSize', 20000);
% Set large timeout in the event of long s-parameter measurement
set(visaObj, 'Timeout', 10);

%% Connect to interface object, visaObj.
fopen(visaObj);

%% Configure parameter to be acquired and initiate 
localConfigurePNA(visaObj,'DB');
numOfPoints = 201; % Hard-code value if required
%numOfPoints = query(visaObj, 'SENS:SWE:POIN?','%s\n','%d');
%% GET S21
fprintf("Collecting S21 data...\n");
localConfigurePNA(visaObj,'RI');
fprintf("PNA configured for S21 data\n");
s21Data = localFetchData(visaObj,'S21');
fprintf("PNA data for S21 fetched\n");
s21_real = s21Data(2,:);
s21_imag = s21Data(3,:);
%s21 = complex(s21Data(2,:),s21Data(3,:));

%% GET S11
fprintf("Collecting S11 data...\n");
localConfigurePNA(visaObj,'RI');
fprintf("PNA configured for S11 data\n");
s11Data = localFetchData(visaObj,'CH1_S11_1');
fprintf("PNA data for S11 fetched");
s11_real = s11Data(2,:);
s11_imag = s11Data(3,:);
%s11 = complex(s11Data(2,:),s11Data(3,:));
clrdevice(visaObj);

frequencies = s11Data(1,:);
S = [s11_real; s11_imag; s21_real; s21_imag];
clrdevice(visaObj);
%% GET S13
%localConfigurePNA(visaObj,'RI');
%s12Data = localFetchData(visaObj,'S12');
%s12 = complex(s12Data(2,:),s12Data(3,:));
%clrdevice(visaObj);
%% GET S14
%localConfigurePNA(visaObj,'RI');
%s22Data = localFetchData(visaObj,'S22');
%s22 = complex(s22Data(2,:),s22Data(3,:));
%clrdevice(visaObj);

%% Reshape and combine the 4 S-parameters to create a 3D matrix. 
% Once in this form, the data can be used by the "S-Parameters Amplifier" 
% block in simulink
%S11 = reshape(s11,1,1,numOfPoints);
%S21 = reshape(s21,1,1,numOfPoints);
%S12 = reshape(s12,1,1,numOfPoints);
%S22 = reshape(s22,1,1,numOfPoints);
%sParameters = [S11 S12; S21 S22]; 
%Caleb - reshape throws a fit and we only are about S21 anyway so just
%returning the following
%% Additional parameters for simulink model, unused in this demo
% sampleTime = 2.5000e-010; 
% centerFrequency = 20.005e9;
% filterLength = 64;
%% Open simulink model from the MATLAB Command line and configure blocks
%  NOTE: This is a non-essential part of the M-File. Once the data is
%  acquired in the above lines of code, it can be processed as required in
%  MATLAB.

% open_system('TxLineModel.mdl')
% set_param('TxLineModel/S-Parameters Amplifier','NetParamData','sParameters',...
% 'NetParamFreq','frequencies','SourceFreq','User-Specified','Freq','frequencies');
%% Close connection, delete visa object
fclose(visaObj);
delete(visaObj);
clear visaObj;

function localWaitForSystemReady(visaObj)
opcStatus = 0;
while(~opcStatus)
    opcStatus = query(visaObj, '*OPC?','%s\n','%d'); 
end

function localConfigurePNA(visaObj,fileFormat)
%% Preset system
% SYSTem:PRESet
% OPC? = All Operations Complete? +1 for Yes
fprintf(visaObj,'SYST:PRES');
localWaitForSystemReady(visaObj);

%% Set S2P File Format. 
fprintf(visaObj, sprintf('MMEM:STOR:TRAC:FORM:SNP %s',fileFormat)); 
% MA - Linear Magnitude / degrees
% DB - Log Magnitude / degrees
% RI - Real / Imaginary
% AUTO - data is output in currently selected trace form

%% Set byte order to swapped (little-endian) format
% FORMat:BORDer <char>
fprintf(visaObj, 'FORM:BORD SWAP');
% NORMal - Use when your controller is anything other than an IBM compatible computers
% SWAPped - for IBM compatible computers

%% Set data type to real 64 bit binary block
% FORMat[:DATA] <char>, 64 for more significant digits and precision
fprintf(visaObj, 'ASCii,0');
% REAL,32 - (default value for REAL) Best for transferring large amounts of measurement data.
% REAL,64 - Slower but has more significant digits than REAL,32. Use REAL,64 if you have a computer that doesn't support REAL,32.
% ASCii,0 - The easiest to implement, but very slow. Use if small amounts of data to transfer.

%set the frequency bounds
fprintf(visaObj, 'SENS:FREQ:CENT 2.7ghz');
fprintf(visaObj, 'SENS:FREQ:SPAN .6ghz');
function data = localFetchData(visaObj,sParameter)
format long;
% Set up the trace corresponding to PARAMETER on the PNA and return DATA,
% a matrix of 2-port S-Parameters in S2P format with specified PRECISION.
% COUNT is the number of values read and MESSAGE tells us if the read
% operation was unsuccessful for some reason.
% Caleb - Had to add in CALC:PAR:SEL to get rid of file format error
%fprintf(visaObj,sprintf('CALC:PAR:SEL %s',sParameter));
fprintf(visaObj,sprintf('CALC:PAR:MOD %s',sParameter));
fprintf("Selected paramater %s \n",sParameter);
localWaitForSystemReady(visaObj);
fprintf(visaObj, 'CALC:DATA:SNP? 2');
fprintf("Read data for %s \n",sParameter);
data = fscanf(visaObj);
localWaitForSystemReady(visaObj);
fprintf("System Ready\n");
data = reshape(data, [(length(data)/9),9]);
data = data';