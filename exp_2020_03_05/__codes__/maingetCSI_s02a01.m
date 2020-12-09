clc
clear
close all
dataName = 's0216b.mat';

%% **** load
fileB = '../s02_1_6G_b/BER_CSI_B_20_03_05_18_01.csv'; % 15_15_36
fileE1 = '../s02_1_6G_b/BER_CSI_E1_20_03_05_18_01.csv';
fileE2 = '../s02_1_6G_b/BER_CSI_E2_20_03_05_18_01.csv';

B = readtable(fileB);
E1 = readtable(fileE1);
E2 = readtable(fileE2);

%% get data
[Bber, Bmag, Bpha] = getInfo(B);
[E1ber, E1mag, E1pha] = getInfo(E1);
[E2ber, E2mag, E2pha] = getInfo(E2);

aB = table2array(B(:,2));
aE1 = table2array(E1(:,2));
aE2 = table2array(E2(:,2));

%% get CSI for data set c
c = 1;
Bcsi = Bmag .* exp(1i.*Bpha);
E1csi = E1mag .* exp(1i.*E1pha);
E2csi = E2mag .* exp(1i.*E2pha);

for ii = 1:25
    if ii == 25
        Bcsi(:,ii) = 1 ./ Bcsi(:,ii);
        E1csi(:,ii) = 1 ./ E1csi(:,ii);
        E2csi(:,ii) = 1 ./ E2csi(:,ii);
    else
        Bcsi(:,ii) = 1 ./ ((Bcsi(:,ii+1)-Bcsi(:,ii))/6 * c + Bcsi(:,ii));
        E1csi(:,ii) = 1 ./ ((E1csi(:,ii+1)-E1csi(:,ii))/6 * c + E1csi(:,ii));
        E2csi(:,ii) = 1 ./ ((E2csi(:,ii+1)-E2csi(:,ii))/6 * c + E2csi(:,ii));
    end
end

figure
subplot(3,1,1);
plot(abs(Bcsi))
title('mag of CSI (B, E1, E2)')
subplot(3,1,2);
plot(abs(E1csi))
subplot(3,1,3);
plot(abs(E2csi))

figure
subplot(3,1,1);
plot(angle(Bcsi))
yyaxis right
plot(table2array(B(:,2)))
title('pha of CSI (B, E1, E2)')
subplot(3,1,2);
plot(angle(E1csi))
yyaxis right
plot(table2array(E1(:,2)))
subplot(3,1,3);
plot(angle(E2csi))
yyaxis right
plot(table2array(E2(:,2)))

%% sort & average with Alice's angle
Bcsi0 = Bcsi;
E1csi0 = E1csi;
E2csi0 = E2csi;
numSub = size(Bcsi0,2);
clear Bcsi E1csi E2csi
aaB = aB;
aaE1 = aE1;
aaE2 = aE2;

% separate a given subcarrier from multiple measurements
for sub = 1:numSub
    [aB, Bcsi(:,sub), indB] = rmDupanew(aaB, Bcsi0(:,sub)); % degree:[0, 360]
    [aE1, E1csi(:,sub), indE1] = rmDupanew(aaE1, E1csi0(:,sub));
    [aE2, E2csi(:,sub), indE2] = rmDupanew(aaE2, E2csi0(:,sub));
end

%% check
sub = 1;
figure
subplot(2,1,1);
plot(aB(1:indB(1)),abs(Bcsi(1:indB(1),sub)))
hold on
title('CSI of B (subchannel 1)')
subplot(2,1,2);
plot(aB(1:indB(1)),angle(Bcsi(1:indB(1),sub)))
hold on
for ii = 2:length(indB)
    s1 = indB(ii-1)+1;
    s2 = indB(ii);
    subplot(2,1,1);
    plot(aB(s1:s2),abs(Bcsi(s1:s2,sub)))
    hold on
    subplot(2,1,2);
    plot(aB(s1:s2),angle(Bcsi(s1:s2,sub)))
    hold on
end

sub = 1;
figure
subplot(2,1,1);
plot(aE1(1:indE1(1)),abs(E1csi(1:indE1(1),sub)))
hold on
title('CSI of E1 (subchannel 1)')
subplot(2,1,2);
plot(aE1(1:indE1(1)),angle(E1csi(1:indE1(1),sub)))
hold on
for ii = 2:length(indE1)
    s1 = indE1(ii-1)+1;
    s2 = indE1(ii);
    subplot(2,1,1);
    plot(aE1(s1:s2),abs(E1csi(s1:s2,sub)))
    hold on
    subplot(2,1,2);
    plot(aE1(s1:s2),angle(E1csi(s1:s2,sub)))
    hold on
end

%% **** extract needed CSI
aB = aB(indB(1)+1:indB(2));
aE1 = aE1(indE1(1)+1:indE1(2));
aE2 = aE2(indE2(1)+1:indE2(2));
Bcsi = Bcsi(indB(1)+1:indB(2),:);
E1csi = E1csi(indE1(1)+1:indE1(2),:);
E2csi = E2csi(indE2(1)+1:indE2(2),:);
figure
subplot(2,1,1);
plot(aB,abs(Bcsi(:,sub)))
hold on
title('check: CSI of B')
subplot(2,1,2);
plot(aB,angle(Bcsi(:,sub)))
hold on

figure
subplot(2,1,1);
plot(aE1,abs(E1csi(:,sub)))
hold on
title('check: CSI of E1')
subplot(2,1,2);
plot(aE1,angle(E1csi(:,sub)))
hold on

%% average CSI over all subcarriers
Bcsi = (mean(Bcsi.')).';
E1csi = (mean(E1csi.')).';
E2csi = (mean(E2csi.')).';

if max(aB)~=360
    aB = [aB;360];
    Bcsi = [Bcsi;Bcsi(end)];
end

if max(aE1)~=360
    aE1 = [aE1;360];
    E1csi = [E1csi;E1csi(end)];
end

if max(aE2)~=360
    aE2 = [aE2;360];
    E2csi = [E2csi;E2csi(end)];
end

if min(aB)~=0
    aB = [0;aB];
    Bcsi = [Bcsi(1);Bcsi];
end

if min(aE1)~=0
    aE1 = [0;aE1];
    E1csi = [E1csi(1);E1csi];
end

if min(aE2)~=0
    aE2 = [0;aE2];
    E2csi = [E2csi(1);E2csi];
end

%% interplot

aaB = (0:1:360)';
aaB = setdiff(aaB,aB);
BBcsi = interp1(aB, Bcsi, aaB);

aB = [aB;aaB];
Bcsi = [Bcsi;BBcsi];
[aB, ind] = sort(aB);
Bcsi = Bcsi(ind);

aaE1 = (0:1:360)';
aaE1 = setdiff(aaE1,aE1);
E1E1csi = interp1(aE1, E1csi, aaE1);

aE1 = [aE1;aaE1];
E1csi = [E1csi;E1E1csi];
[aE1, ind] = sort(aE1);
E1csi = E1csi(ind);

aaE2 = (0:1:360)';
aaE2 = setdiff(aaE2,aE2);
E2E2csi = interp1(aE2, E2csi, aaE2);

aE2 = [aE2;aaE2];
E2csi = [E2csi;E2E2csi];
[aE2, ind] = sort(aE2);
E2csi = E2csi(ind);

figure
plot(aB,abs(Bcsi))
title('mag of averaged CSI')
figure
plot(aB,angle(Bcsi))
title('pha of averaged CSI')

%% **** save
save(dataName,'Bcsi','aB','E1csi','aE1','E2csi','aE2')