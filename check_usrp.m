clc
clear

disp('Checking for USRP support package...')
disp('')

which comm.SDRuReceiver
which comm.SDRuTransmitter

disp('')
disp('Installed products:')
ver