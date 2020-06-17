%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measures synchrony/stability among random unique pairs and for a duration
% 
%
% Arguments: 
%          periodicity: '7' denotes chaotic-, '2' double periodic, and '1'
%          single periodic
%          sim_dat_file: simulated data from CARLsim
%          scale: number of neurons in the network
%          hil_start: time onset for the analysis
%          duration: duration for the analysis
%          n_pairs: number of neuron pairs
%          nrns1: set-1 of neurons
%          nrns2: set-2 of neurons to be paired with set-1
%
% Returns synchrony/stability measures in [0 1] and the average phase difference
% Returns the number of pairs that were deemed to be stable
%
% This function requires CARLsim OAT to extract spike times:
%          http://uci-carl.github.io/CARLsim4/ch9_matlab_oat.html#ch9s5_reading_raw_data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [synchrony, modes, n_syncs]=measure_sync(periodicity, sim_dat_file, scale, hil_start, duration, n_pairs, nrns1, nrns2)
    %nrns_1 = randi([0 49], 1, n_pairs);
    %nrns_2 = randi([50 99], 1, n_pairs); 
    if isempty(nrns1)
        nrns_1 = randperm(scale/2, n_pairs)-1;
    else
        nrns_1 = nrns1;
    end
    if isempty(nrns2)
        nrns_2 = randperm(scale/2, n_pairs)-1 +scale/2;
    else
        nrns_2 = nrns2;
    end
     
    synchrony = zeros(1,n_pairs);
    modes = 9*ones(1, n_pairs);
    n_syncs = 0;
    
    SR_inh = SpikeReader(sim_dat_file);   
    %
    % 'wnd' is the length of a burst cycle used for Gaussian convolution (see below) 
    % See Fig S1 in the article for details of obtaining 'wnd' values
    % 
    if periodicity==7
         wnd=97;
    end    
    if periodicity==2
         wnd=139;
    end
    if periodicity==1
         wnd=37; 
    end
        
    binWindow=-1;
    ign_last_t = 100; 
    g=gausswin(wnd);
    g=g/sum(g);  
        
    %row 1 - spike times
    %row 2 - neuron IDs
    spk_inh = SR_inh.readSpikes(binWindow); 
    temp = spk_inh(2,:);
    
    for idx=1:n_pairs
        nrn1=nrns_1(idx);
        nrn2=nrns_2(idx);
        spike_times1 = spk_inh(1, temp==nrn1);
        spike_times2 = spk_inh(1, temp==nrn2);

        spikes1=-ones(1,duration);
        spikes1(spike_times1)=1;
        spikes2=-ones(1,duration);
        spikes2(spike_times2)=1;
        
        signal1 =conv(spikes1(1, :), g, 'same');
        signal2 =conv(spikes2(1, :), g, 'same');
        
        signal1=signal1(hil_start:duration-ign_last_t);
        signal2=signal2(hil_start:duration-ign_last_t);

        signal1=-((max(signal1)+min(signal1)) / 2)+ signal1;
        signal2=-((max(signal2)+min(signal2)) / 2)+ signal2;
        
        hb1 = hilbert(signal1);
        ph_signal1=((wrapTo2Pi(angle(hb1))));
        hb2 = hilbert(signal2);
        ph_signal2=((wrapTo2Pi(angle(hb2))));
        ph_diff =(ph_signal1-ph_signal2);   

        Z=mean(exp(1i*ph_diff));
        synchrony(idx) = abs(Z);
        degrees = rad2deg(wrapTo2Pi(angle(Z)));
        modes(idx)=9;
        
        if synchrony(idx)>=0.95           
           if degrees<=60 || degrees>300
                 modes(idx)=0;
           end
           if degrees<=180 && degrees>60
                 modes(idx)=1;
           end
           if degrees<=300 && degrees>180
                 modes(idx)=2;
           end
           
           n_syncs = n_syncs +1;
        end

    end
    clear temp;
    
end