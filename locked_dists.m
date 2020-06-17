%
% Return distributions of locked durations, state transition matrix and
% other relevant metrics
% Plot distributions of locked durations
%

state_seq_dir='C:\state_seq_dir\'; 

[locked_durs,...
accumulate_locked_0phase, accumulate_locked_120phase, accumulate_locked_240phase,...
expected_life_time, escape_prob, successful_trans_prob, stm]=...
                                                                complexity_core(state_seq_dir, 1, 100);
mode_0_relative_stability = locked_durs(1)/max(locked_durs);
mode_1_relative_stability = locked_durs(2)/max(locked_durs);
mode_2_relative_stability = locked_durs(3)/max(locked_durs);
%plot parms                                                            
clrs=[0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];
clr_idx=1;
fontsize=8;
xlim_max=10;
ylim_min=0;
ylim_max=0.6;
xlim_min=0.5;
edges=0:.5:120;

subplot(2,2,1);
h=histogram((accumulate_locked_0phase/1000),edges,...
    'FaceColor', clrs(clr_idx,:), 'EdgeColor', clrs(clr_idx,:),...
    'FaceAlpha', 0.6, 'EdgeAlpha', 0.6,...
    'Normalization', 'count'); hold on;        
pd0=fitdist((accumulate_locked_0phase/1000),'Exponential');
y = exppdf(edges,pd0.mu);
p=plot(edges, (y), 'k-'); hold off;
xlabel('locked duration (s)');
%ylabel('p.d.');
legend([h p], {'mode 0' ,strcat('^{1}/{\lambda} =',' ', num2str(round(pd0.mu, 2)), 's')});
xlim([xlim_min xlim_max]); 
%ylim([ylim_min ylim_max]); 
legend boxoff;       
set(gca, 'FontSize', fontsize);

subplot(2,2,2);
h=histogram((accumulate_locked_120phase/1000),edges,...
    'FaceColor', clrs(clr_idx,:), 'EdgeColor', clrs(clr_idx,:),...
    'FaceAlpha', 0.6, 'EdgeAlpha', 0.6,...
    'Normalization', 'pdf'); hold on;        
pd1=fitdist(accumulate_locked_120phase/1000,'Exponential');
y = exppdf(edges,pd1.mu);
p=plot(edges, (y), 'k-'); hold off;
xlabel('locked duration (s)');
%ylabel('p.d.');
legend([h p], {'mode ^{2\pi}/3' ,strcat('^{1}/{\lambda} =',' ', num2str(round(pd1.mu, 2)), 's')});
xlim([xlim_min xlim_max]); 
ylim([ylim_min ylim_max]); 
legend boxoff;    
set(gca, 'FontSize', fontsize);

subplot(2,2,3);
h=histogram((accumulate_locked_240phase/1000),edges,...
    'FaceColor', clrs(clr_idx,:), 'EdgeColor', clrs(clr_idx,:),...
    'FaceAlpha', 0.6, 'EdgeAlpha', 0.6,...
    'Normalization', 'pdf'); hold on;        
pd2=fitdist(accumulate_locked_240phase/1000,'Exponential');
y = exppdf(edges,pd2.mu);
p=plot(edges, (y), 'k-'); hold off;
xlabel('locked duration (s)');
%ylabel('p.d.');
legend([h p], {'mode ^{4\pi}/3' ,strcat('^{1}/{\lambda} =',' ', num2str(round(pd2.mu, 2)), 's')});
xlim([xlim_min xlim_max]); 
ylim([ylim_min ylim_max]); 
legend boxoff;    
set(gca, 'FontSize', fontsize);
%
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPosition = [100 100 10.5 7];

print('C:\fig2_dists.svg', '-dsvg');
