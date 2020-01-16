% 
% Identify sequences of states along with their locked durations for the
% pairs defined in nck.csv
%

% periodicity: '7' denotes chaotic-, 
%              '2' double periodic, and 
%              '1' single periodic
periodicity=2;
   
sim_dat_file='C:\sim.dat'; %output file from CARLsim simulation
state_seq_dir='C:\state_seq_dir\'; %output directory to write state sequences into

%read all possible pair combinations
nck_file='C:\nck.csv';
pairs = csvread(nck_file);

scale=100; %total number of neurons in the network
n_pairs= 1; %space
start=5000; %time onset
finish=120000; %time offset

N_window_sequences= floor((finish-start)/window_length);    
%
for pair=1:100
    pp=pair
    nrns_1 = pairs(pair,1);
    nrns_2 = pairs(pair,2);
    %
    hil_start = start;    
    all_window_modes = 9*ones(1, N_window_sequences);
    mode=9;    
    for window=1:N_window_sequences     
        sim_dur=hil_start + 100 + (window_length);          
        [syncny modes n_syncs] = measure_sync(periodicity, sim_dat_file, scale, hil_start, sim_dur, n_pairs, nrns_1, nrns_2);          
        all_window_modes(window)=modes(1);%
        hil_start= hil_start + window_length;
    end
    all_stable_modes=9*ones(1, length(all_window_modes));
    all_stable_durs=zeros(1, length(all_window_modes));

    idx2=1;    
    for idx=2:length(all_window_modes) 
        all_stable_durs(idx2)=  all_stable_durs(idx2)+window_length;        
        if all_window_modes(idx)~=all_window_modes(idx-1) %end of a stable state
            all_stable_modes(idx2)=all_window_modes(idx-1);            
            idx2=idx2+1;
            continue;
        end        
        if idx==length(all_window_modes) %also record the last mode, that may or may not persist beyond 'finish'
            all_stable_modes(idx2)=all_window_modes(idx); 
        end
    end

    %filter 0s (tail)
    all_stable_durs = all_stable_durs(all_stable_durs~=0);
    all_stable_modes = all_stable_modes(1:length(all_stable_durs));
    if record_locked_modes==1
        %filter 9s    
        all_stable_modes_no9s=all_stable_modes(find(all_stable_modes~=9));
        all_stable_durs_no9s = all_stable_durs(find(all_stable_modes~=9));

        fname_id=strcat(num2str(nrns_1), '_', num2str(nrns_2));
        csvwrite(strcat(state_seq_dir, fname_id, '.csv'),[all_stable_modes_no9s; all_stable_durs_no9s]');
    else
        all_switching_modes_9s=all_stable_modes(find(all_stable_modes==9));
        all_switching_durs_9s = all_stable_durs(find(all_stable_modes==9));

        if length(all_switching_modes_9s)==0
            all_switching_modes_9s=9;
            all_switching_durs_9s=0;
        end
        fname_id=strcat(num2str(nrns_1), '_', num2str(nrns_2));
        csvwrite(strcat(state_seq_dir, fname_id, '_trans_durs.csv'),[all_switching_modes_9s; all_switching_durs_9s]');
    end
end
