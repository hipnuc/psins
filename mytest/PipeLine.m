function [posdr,posdr0,posdr1] = PipeLine(imuod, t, pos, yaw0, inst, kod, Td)
% ���������
%   imuod = [gx,gy,gz, ax,ay,az, od, t];  gx,gy,gz ������/rad����ǰ�ϣ�; ax,ay,az �ٶ�����/(m/s); od ��̼ƾ�������/m; t ʱ��/s
%   t = [t0, t1, t2];  t0 ��ʼʱ�䣬ȷ��֮��10s��ֹ;  t1 ����ĩ��ʱ�䣬ȷ��ǰ��20s����ֹ;  t2 �س�ĩ��ʱ��
%   pos = [pos0; pos1]  pos0 ��ʼλ�ã�γ��rad����m��; pos1 ����ĩ��λ��
%   yaw0 ��ʼ��λ��/rad ��ƫ��Ϊ�� -pi -> pi
%   inst �ߵ���װƫ�� [����ƫ��; 0; ��λƫ��]/rad,  Ĭ��Ϊ [0;0;0]
%   kod ��̶̿�ϵ����m/���壩,  Ĭ��Ϊ 1
%   Td ��ƽʱ�䳣��,  Ĭ��Ϊ 0
% ���������
%   posdr = �������ں�λ�ã�γ��rad����m��
%   posdr0,posdr1 = ��������λ��
    t0 = t(1); t1 = t(2); t2 = t(3);
    pos0 = pos(1,1:3)';  pos1 = pos(2,1:3)';
    if nargin<7, Td=0; end
    if nargin<6, kod=1; end
    if nargin<5, inst=zeros(3,1); end
    glvwie(0);
    %%
    imuod = imuresample(imurepair(imuod),0.01,0,'spline',0);  % imuplot(imuod(:,[1:7,8]),1); odplot(imuod(:,7:8));
    att = alignsb(datacut(imuod,t0,t0+10),pos0); att(3) = yaw0;
    imuod(:,[1:6,8]) = imudeldrift(imuod(:,[1:6,8]), t1-10,t1+10);
    avp = drpure(datacut(imuod,t0,t2), [att;pos0], inst, kod, Td); close(gcf); % insplot(avp);
    pos1DR = getat(avp,t1);
    [inst1, kod] = drcalibrate(avp(1,7:9)', pos1, pos1DR(7:9));
    avp = drpure(datacut(imuod,t0,t2), [att-inst1;pos0], inst, kod, Td); % insplot(avp);
    %%
    posdr0 = drfit(datacut(avp(:,[7:9,end]),1,t1), pos0, pos1, 1);  title('forward fit');
    posdr1 = drfit(datacut(avp(:,[7:9,end]),t1,t2), pos1, pos0, 1);  title('backward fit');
    posdr = drfusion(posdr0, posdr1, 1, 2); 
    glvwie(1);



