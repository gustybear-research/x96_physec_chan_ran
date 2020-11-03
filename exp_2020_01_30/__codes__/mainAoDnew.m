clc
clear
close all

%% **** data
name_f = '2_6G';
name_ind = '_02';

name1 = ['exDatas02_' name_f name_ind '.mat'];
load(name1) % CSI of RX is Bcsi
fprintf('Filename1: %s \n',name1);

name2 = ['arrayResponseAll_' name_f '.mat'];
load(name2); % antenna gain: row: direction, column: antenna mode
fprintf('Filename2: %s \n',name2);

fig1 = '';

%% parameters
D = 182;
numSamples = 20;
alpha0 = 0.4;
alpha = 1;

seed = rng;
% load test.mat
% rng(seed)

%% **** reproduction
name3 = ['pars02_' name_f name_ind '.mat'];
load(name3)
fprintf('Filename3: %s \n',name3);
rng(seed)
disp('********** reproduce saved results **********')

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

ind = [0:1:90, 270:1:360]+1;
arrayResponseAll0 = arrayResponseAll;
arrayResponseAll0(:,92:270) = 0;
arrayResponseAll0(92:270,:) = 0;
arrayResponseAll = arrayResponseAll(:,ind);
arrayResponseAll = arrayResponseAll(ind,:);

%% AoD ground truth

arrayResponseSet = arrayResponseAll;
arrayResponseSet =  arrayResponseSet';

% a0 = arrayResponseSet\Bcsi;

cvx_begin quiet
variable a0(D) complex
minimize(norm(arrayResponseSet * a0 - Bcsi, 2)  + alpha0 * norm(a0, 1) + (1-alpha0)*norm(a0, 2))
cvx_end

%% AoD estimation
modeSet = randperm(D,numSamples);
hSet = Bcsi(modeSet);

arrayResponseSet = arrayResponseAll(:,modeSet);
arrayResponseSet = arrayResponseSet';

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

tempa0 = zeros(361,1);
tempa0(1:91) = a0(1:91);
tempa0(271:361) = a0(92:end);
tempa = zeros(361,1);
tempa(1:91) = a(1:91);
tempa(271:361) = a(92:end);
a0 = tempa0;
a = tempa;
theta = (1:1:361);

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
name5 = ['./figures/AoD02_' name_f name_ind '.eps'];
print(fig,'-deps', name5)

BBcsi = zeros(361,1);
BBcsi(1:91) = Bcsi(1:91);
BBcsi(271:361) = Bcsi(92:end);
figure
plot((0:1:360)',abs(BBcsi),'k','LineWidth',1.2)
hold on
plot((0:1:360)',abs(arrayResponseAll0.'*a),'k--','LineWidth',1.2) % predicted CSI
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
name5 = ['./figures/pred02_' name_f name_ind '.eps'];
print(fig,'-deps', name5)

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
% save('pars02_1_6_G_01.mat','seed','numSamples','alpha0','alpha')
% disp('********** saved **********')