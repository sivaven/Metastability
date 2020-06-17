%
% Autocorrelation of core composition
%
% Also see Kasatkin et al. (eqn-4):
% Kasatkin DV, Klinshov VV, Nekorkin VI. 
% Itinerant chimeras in an adaptive network of pulse-coupled oscillators. 
% Physical Review E. 2019 Feb 7;99(2):022203.
%

cohdomains=csvread('C:\cohdomains.csv');
%
% "cohdomains" is a 2D matrix of size 100 x 220.
% see output of coherent_domains.m
% one row for each neuron
% one column for each delta_t (500ms, sequentially)
%

mean_core_size=mean(sum(cohdomains)); %<M> in Kasatkin eqn-4
res=1;

delays=0:1:(res*20); %horizontal axis for autocorrelation. Compute autocorrelation for 0 to 10sec delay 
A=zeros(1, length(delays)); %A(tau) in Kasatkin eqn-4

for delay=delays %"tau" in Kasatkin eqn-4
    sum_over_0_to_T=0;
    for delta_t_idx=1:res*200 % "T" in Kasatkin eqn-4 is 200 here
        sum_over_0_to_T = sum_over_0_to_T +...
        sum(cohdomains(:,delta_t_idx).*cohdomains(:, delta_t_idx+delay)); %sum under the integral in Kasatkin eqn-4
    end
    time_average = sum_over_0_to_T/(res*200); % 1/T outside the integral in Kasatkin eqn-4
    A(delay+1)=time_average/mean_core_size;
end

plot(delays*(500/res)/1000, A, '-','color', [0.25 0.25 0.25],'LineWidth', .75);

ylabel('autocorrelation');
xlabel('delay (s)');
ylim([.75 1]);
xlim([0 5]);
grid on;


set(gca, 'fontsize', 7);
fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [100 100 2.5 1.25];
print('C:\autocorr', '-dsvg');
