clc
clear
close all

%% **** data
name_f = '2_4G';
name_ind = '_1LOS_30dB_500k_Slow';

name1 = ['./extractedData/data' name_ind '.mat'];
load(name1)

name2 = ['arrayResponseAll_' name_f '.mat'];
load(name2); % antenna gain: row: direction, column: antenna mode
fprintf('Filename2: %s \n',name2);

fig1 = '';

%% filter out 1 & 361
ind1 = find(aB == 1);
ind2 = find(aB == 361);
ind = union(ind1, ind2);
aB(ind) = [];
Bcsi(ind,:) = [];

%% parameters
D = 361;
numSamples = 40;
alpha0 = 0.7;
alpha = 0.6;

% seed = rng;
% seed = rng('default');
seed = rng(2020);

%% **** reproduction
% name3 = ['pars02_' name_f name_ind '.mat'];
% load(name3)
% fprintf('Filename3: %s \n',name3);
% rng(seed)
% disp('********** reproduce saved results **********')

%%
% resort mode index according to experiment
[tempind, ind] = max(arrayResponseAll);
[tempind, ind1] = sort(ind);
arrayResponseAll = arrayResponseAll(:,ind1);

figure
polarplot((0:pi/180:2*pi)',arrayResponseAll(:,45),'k','LineWidth',1.2)
set(gca,'FontSize',12,'Color',[245, 245, 245]/255)
fig = get(groot,'CurrentFigure');
fig.PaperPositionMode = 'auto';
fig.Color = [245, 245, 245]/255;
fig.InvertHardcopy = 'off';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
name4 = ['./figures/pattern' name_f '.eps'];
print(fig,'-deps', name4)

%% AoD ground truth
arrayResponseSet = arrayResponseAll;
arrayResponseSet =  arrayResponseSet';

% sort arrayResponseSet with order
temp = arrayResponseSet(aB,:);
arrayResponseSet = temp;

% a0 = arrayResponseSet\Bcsi;

cvx_begin quiet
variable a_temp(D) complex
minimize(norm(arrayResponseSet * a_temp - Bcsi(:,end), 2))
% minimize(norm(arrayResponseSet * a0 - Bcsi(:,end), 2)  + alpha0 * norm(a0, 1) + (1-alpha0)*norm(a0, 2))
cvx_end

% method 1
% w = (1 ./ abs(a_temp)).^2;
% w = w ./ sum(w);

% method 2
% y = ones(361,1);
% y(1:60) = 3;
% figure
% plot(y)
% w = y;
% w = w .* y;

w = 1;
cvx_begin quiet
variable a0(D) complex
% minimize(norm(arrayResponseSet * a0 - Bcsi(:,end), 2))
minimize(norm(arrayResponseSet * a0 - Bcsi(:,end), 2)  + alpha0 * norm(w .* a0, 1) + (1 - alpha0) * norm(w .* a0, 2))
cvx_end

% a0_lasso = lasso(arrayResponseSet, Bcsi(:,end));

% a0 = a_temp;

%% AoD estimation
temp = unique(aB);
modeSet = randperm(length(temp),numSamples);
modeSet = temp(modeSet);

ind = [];
for ii = 1:numSamples
    temp = find(aB==modeSet(ii));
    ind = [ind;temp];
end
modeSet = ind;

hSet = Bcsi(modeSet,end);

arrayResponseSet = arrayResponseSet(modeSet,:);

% AoD estimation code
% cvx_begin quiet
% variable a(D) complex
% minimize(norm(a, 1))
% subject to
% arrayResponseSet * a == hSet
% cvx_end

cvx_begin quiet
variable a(D) complex
minimize(norm(arrayResponseSet * a - hSet, 2)  + alpha * norm(a, 1) + (1-alpha)*norm(a, 2))
cvx_end

figure;
polarplot((0:pi/180:2*pi)',abs(a0),'k','LineWidth',1.2)
hold on
polarplot((0:pi/180:2*pi)',abs(a),'k--','LineWidth',1.2)
legend('ground truth','estimation','FontSize',12,'Location','south')
set(gca,'FontSize',12,'Color',[245, 245, 245]/255)
fig = get(groot,'CurrentFigure');
fig.Color = [245, 245, 245]/255;
fig.PaperPositionMode = 'auto';
fig.InvertHardcopy = 'off';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
name5 = ['./figures/AoD_' name_f name_ind '.eps'];
print(fig,'-deps', name5)

figure
plot(aB,abs(Bcsi(:,end)),'k','LineWidth',1.2)
hold on
plot((0:1:360)',abs(arrayResponseAll.'*a),'k--','LineWidth',1.2) % predicted CSI
legend({'measured','predicted'},'FontSize',12,'Location','best')
xlim([0 360])
xlabel('Antenna mode')
ylabel('Magnitude of CSI')
set(gca,'FontSize',12,'Color',[245, 245, 245]/255)
fig = get(groot,'CurrentFigure');
fig.PaperPositionMode = 'auto';
fig.Color = [245, 245, 245]/255;
fig.InvertHardcopy = 'off';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
name5 = ['./figures/pred_' name_f name_ind '.eps'];
print(fig,'-deps', name5)

figure
plot(aB,abs(Bcsi(:,end))/max(abs(Bcsi(:,end))),'k','LineWidth',1.2)
hold on
plot((0:1:360)',abs(arrayResponseAll.'*a)/max(abs(arrayResponseAll.'*a)),'k--','LineWidth',1.2) % predicted CSI
legend({'measured','predicted'},'FontSize',12,'Location','best')
xlim([0 360])
xlabel('Antenna mode')
ylabel('Magnitude of CSI')
title('Normalized')
set(gca,'FontSize',12,'Color',[245, 245, 245]/255)
fig = get(groot,'CurrentFigure');
fig.PaperPositionMode = 'auto';
fig.Color = [245, 245, 245]/255;
fig.InvertHardcopy = 'off';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

% figure
% plot((0:1:360)',angle(BBcsi))
% hold on
% plot((0:1:360)',angle(arrayResponseAll0.'*a)) % predicted CSI
% legend({'measured','predicted'},'FontSize',12)
% xlim([0 360])
% xlabel('Antenna mode')
% ylabel('Phase of CSI')
% set(gca,'FontSize',12)

%% **** save
% save('pars2tx6.mat','seed','numSamples','alpha0','alpha')
% disp('********** saved **********')