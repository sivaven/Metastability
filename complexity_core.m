%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns the distributions of locked durations, state
% transition matrix at the level of individual pairs and other relevant metrics
% 
% Arguments: state_seq_dir: output directory of generate_state_sequences.m    
%            pair_begin_idx: index of the first pair
%            pair_end_idx: index of the last pair   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [locked_durs, accumulate_locked_0phase, accumulate_locked_120phase, accumulate_locked_240phase, expected_life_time, escape_prob, trans_prob, state_trans_mat]=...
                            complexity_core(state_seq_dir, pair_begin_idx, pair_end_idx)  
   
                   
    nck_file='C:\nck.csv';
    pairs = csvread(nck_file);    
    accumulate_locked_0phase=[];
    accumulate_locked_120phase=[];
    accumulate_locked_240phase=[];

    state_trans_mat = zeros(3,3);
    escape_prob = zeros(3,1);
    locked_durs = zeros(3,1);
    trans_prob = zeros(3,2);
    expected_life_time = zeros(3,1);
    
    n_pairs=pair_end_idx-pair_begin_idx+1;
    
    for pair=pair_begin_idx:pair_end_idx
        nrns_1 = pairs(pair,1);
        nrns_2 = pairs(pair,2);    
        fname_id=strcat(num2str(nrns_1), '_', num2str(nrns_2));
        pair_file=dir(strcat(state_seq_dir,fname_id,'.csv'));
        
        if(pair_file.bytes<1)
            continue
        end
        locked = csvread(strcat(state_seq_dir,fname_id,'.csv'));
        %
        % stability 
        %
        accumulate_locked_0phase = [accumulate_locked_0phase; locked((locked(:,1)==0),2)]; 
        accumulate_locked_120phase = [accumulate_locked_120phase; locked((locked(:,1)==1),2)]; 
        accumulate_locked_240phase = [accumulate_locked_240phase; locked((locked(:,1)==2),2)]; 
        %
        % escape prob
        %        
        state_sequence = locked(:,1);
        for sequence=1:length(state_sequence)-1       
            state_trans_mat(state_sequence(sequence)+1, state_sequence(sequence+1)+1) =...
                state_trans_mat(state_sequence(sequence)+1, state_sequence(sequence+1)+1) +1;
        end        
    end
    
    ids=[1 2 3];
    for id=1:1:3
            if sum(state_trans_mat(id, :))==0
                escape_prob(id)=0;
            else
                total_transitions = state_trans_mat(id, 1) + state_trans_mat(id, 2) + state_trans_mat(id, 3); 
                escape_prob(id) = 1-(state_trans_mat(id, id)/total_transitions); 
                successful_transitions = state_trans_mat(id, ids(ids~=id));
                trans_prob(id, 1)= successful_transitions(1)/total_transitions;
                trans_prob(id, 2)= successful_transitions(2)/total_transitions;
            end
    end
    
    %total duration = 2 mins - 5 seconds (5 seconds of discarded transients)
    locked_durs(1)=sum(accumulate_locked_0phase)/(115000*n_pairs); 
    locked_durs(2)=sum(accumulate_locked_120phase)/(115000*n_pairs);
    locked_durs(3)=sum(accumulate_locked_240phase)/(115000*n_pairs);
    
    if isempty(accumulate_locked_0phase)
        expected_life_time(1)=0;
    else
        expected_life_time(1)=mean(accumulate_locked_0phase/1000);
    end
    if isempty(accumulate_locked_120phase)
        expected_life_time(2)=0;
    else
        expected_life_time(2)=mean(accumulate_locked_120phase/1000);
    end
    if isempty(accumulate_locked_240phase)
        expected_life_time(3)=0;
    else
        expected_life_time(3)=mean(accumulate_locked_240phase/1000);
    end
   
end