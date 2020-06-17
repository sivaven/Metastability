%
% Prepare core composition over time for autocorrelation
%
periodicity=2;
delta_t=500; %ms
sync_with_n_thresh=1;

scale=100;
sim_dat_file='C:\sim.dat'; %output file from CARLsim simulation
n_windows=220; 
%autocorr_core=zeros(n_trials, n_windows);

START=5000; %
coh_domain=zeros(scale, n_windows);

for window=1:n_windows
    n_pairs=1;
    hil_start = START+ (window-1)*delta_t; 
    sim_dur = hil_start + 100 + delta_t;

    for nrn_i=0:scale-1    
        sync_with_n=0;
        for nrn_j=0:scale-1
            if nrn_j==nrn_i
                continue;
            end

            nrns_1 = nrn_i;
            nrns_2 = nrn_j;
            [syncny, modes, n_syncs] = measure_sync(periodicity, sim_dat_file,...
                scale, hil_start, sim_dur, n_pairs, nrns_1, nrns_2); 

            if syncny(1)>=0.95
                sync_with_n = sync_with_n + 1;
            end            
            if sync_with_n >= sync_with_n_thresh % break; move on to next i
                coh_domain(nrn_i+1, window)=1;
                break;
            end
        end
    end        
end
csvwrite('C:\cohdomains.csv', coh_domain);

