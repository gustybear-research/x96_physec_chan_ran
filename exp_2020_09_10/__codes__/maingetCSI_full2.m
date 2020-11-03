clc
clear
close all

%% **** load
% fileB = './1LOS_15dB_500k/BER_CSI_B_20_09_10_16_16.csv';
% fileB = './1LOS_30dB_500k/BER_CSI_B_20_09_10_16_09.csv';
fileB = './1LOS_30dB_500k_Slow/BER_CSI_B_20_09_10_16_51.csv';
% fileB = './1LOS_Reflector_15dB_500k/BER_CSI_B_20_09_10_16_39.csv';
% fileB = './1LOS_Reflector_30dB_500k/BER_CSI_B_20_09_10_16_36.csv';
% fileB = './1LOS_Reflector_30dB_500k_Slow/BER_CSI_B_20_09_10_17_01.csv';
% fileB = './2LOS_15dB_500k/BER_CSI_B_20_09_10_16_24.csv';
% fileB = './2LOS_30dB_500k/BER_CSI_B_20_09_10_16_21.csv';
% fileB = './2LOS_30dB_500k_Slow/BER_CSI_B_20_09_10_16_56.csv';
% name_ind = '_2LOS_30dB_500k_Slow';

name_ind = '_1LOS_30dB_500k_Slow';

B = readtable(fileB);

%% get data
[Bber, Bmag, Bpha] = getInfo2(B);

aB = table2array(B(:,2));

%% get CSI for data set c
c = 1;
Bcsi = Bmag .* exp(1i.*Bpha);

for ii = 1:25
    if ii == 25
        Bcsi(:,ii) = 1 ./ Bcsi(:,ii);
    else
        Bcsi(:,ii) = 1 ./ ((Bcsi(:,ii+1)-Bcsi(:,ii))/6 * c + Bcsi(:,ii));
    end
end

figure
subplot(2,1,1);
plot(abs(Bcsi))
title('mag of CSI')
subplot(2,1,2);
plot(angle(Bcsi))
title('pha of CSI')

%%
% find the end of the cycle
indB = rmDupanew2(aB); 

% discard the value of the first cycle that start from 270
aB(1:indB(1)) = [];
Bcsi(1:indB(1),:) = [];

% make aB to [1,361]
aB = aB + 1;

%%
figure
subplot(2,1,1)
plot(aB,abs(Bcsi),'k','LineWidth',1.2)
xlabel('Antenna mode')
ylabel('Magnitude of CSI')
set(gca,'FontSize',12,'Color',[245, 245, 245]/255)
xlim([0 360])
subplot(2,1,2)
plot(aB,angle(Bcsi),'k','LineWidth',1.2)
xlabel('Antenna mode')
ylabel('Phase of CSI')
set(gca,'FontSize',12,'Color',[245, 245, 245]/255)
xlim([0 360])
fig = get(groot,'CurrentFigure');
fig.PaperPositionMode = 'auto';
fig.Color = [245, 245, 245]/255;
fig.InvertHardcopy = 'off';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
name5 = ['./figures/CSI' name_ind '.eps'];
print(fig,'-deps', name5)

%% **** save
dataname = ['./extractedData/data' name_ind '.mat'];
save(dataname,'Bcsi','aB')
% disp('********** saved **********')