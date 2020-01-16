%
% Plot raster diagram from CARLsim simulation data
% Refer to Chapter 9: MATLAB Offline Analysis Toolbox (OAT) of CARLsim 4.0 
% for prerequisites http://uci-carl.github.io/CARLsim4/ch9_matlab_oat.html
%
sim_dat_file1='C:\sim.dat'; %output of CARLsim simulator
b1=15000;% beginning of time window in ms
e1=16000;% end of time window in ms
%
%Read raw simulation data
%Identify spike times of neurons
%
SR_inh = SpikeReader(sim_dat_file1);
binWindow=-1;
spk_inh = SR_inh.readSpikes(binWindow); %row 1 - spike times, row 2 - neuron IDs 
temp=spk_inh(1,:);
id1_inh=find(temp>b1 & temp<=e1);
clear temp

%plot
mksz=3;
plt_width=2.5;
plot(spk_inh(1,id1_inh)/1000, spk_inh(2,id1_inh), '.k', 'MarkerSize', mksz);
xlim([b1/1000 e1/1000]);
ylim([0, 100]);
xlabel('time (s)')
ylabel('neuron ID')
%title(strcat('Neurons', num2str(nrn1),'thru', num2str(nrn2)))
grid on;
grid minor;
set(gca, 'FontSize', 6);
 
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [100 100 plt_width 1.9-.2];

print(strcat('C:\rast.svg'), '-dsvg');
  

