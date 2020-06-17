%
% *Itinerant Chimeras*
% Size of the coherent domain (core size) against time
%
periodicity=2;
delta_t=500; %ms
n_windows=500;
sync_with_n_thresh=1;

core_size=zeros(1, n_windows);
sim_dat_file='C:\sim.dat'; %output file from CARLsim simulation   
    
for window=1:n_windows
    n_pairs=1;
    hil_start = 5000+ (window-1)*100;
    sim_dur = hil_start + 100 + delta_t;

    coh_domains = zeros(1, scale);
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
                coh_domains(nrn_i+1)=1;
                break;
            end

        end
    end
    core_size(1, window)=sum(coh_domains);

end
