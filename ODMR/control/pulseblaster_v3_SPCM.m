clc,clear,close all
%% configure bits
Trig_bit = 5;
AOM_bit = 0;
CAM_bit = 2;
MWswitch_bit = 1;
DAQ_bit = 4;
USB6211_SampleClock_bit = 8;
SPCM_gating_bit = 7;

%% input parameters
t_AOM = 3000;       %ns
t_Readout = 500;
t_MW = 100;         %ns, for delay measurement
t_CAM = 100;        %ns, for delay measurement
t_CAMoff = 1e7;     %ns
t_start = 0;        %ns
t_end = 400;       %ns
t_blank = 0;      %ns
t_delay = 880;        %ns
t_SPCM = 200;

points =41;
cycles = 20000;

freq = 250e6;       %Hz

pulseType = 'T1';
Ref = 'periodic';
%%
t_min = 1/freq * 1e9 * 5;          %ns
tau_min = 1/freq * 1e9;
step = (floor(((t_end-t_start)/(points-1))/tau_min) + 1) * tau_min;
tau = t_start + (0:points-1) * step;

tau(find(tau<30)) = 20;
if t_start == 0
    tau(1) = 0;
end
%% Convert dec2bin
Head = 2^21 + 2^22 + 2^23;
AOMcontrol = 2^AOM_bit;
MWcontrol = 2^MWswitch_bit;
CAMcontrol = 2^CAM_bit;
DAQcontrol = 2^DAQ_bit;
TRIGcontrol = Head + 2^Trig_bit;
SPCMcontrol = 2^USB6211_SampleClock_bit + 2^SPCM_gating_bit;
%% 
space = '           ';
ns = 'ns';
OffSeq = [space,'0b',num2str(dec2bin(Head)),', '];
LaserCAMSeq = [space,'0b',num2str(dec2bin(Head + AOMcontrol + CAMcontrol)),', '];
CAMSeq = [space,'0b',num2str(dec2bin(Head + CAMcontrol)),', '];
%% Header
fprintf(['//','Readout Delay','\n']);
fprintf(['//','Author: XY','\n']);
fprintf(['//','LASER = ', num2str(t_AOM),' ns','\n']);
fprintf(['//','Total frames = ', num2str(points * 2),'\n']);
fprintf('\n');
%%
t = [];
Ref_t = [];
bitcontrol = {};
Refbitcontrol = {};
RunTime = [];

for i = 1:points
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Signal%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if tau(i) == 0
%         RefRunTime(i) = cycles * (tau(i) + t_AOM);             
%         fprintf([LaserCAMSeq, num2str(t_AOM/2),' ns',... 
%             ', ','loop',', ',num2str(cycles),...
%                '   //',num2str(RefRunTime(i)/1e6),' ms','\n']);               
%         fprintf([LaserCAMSeq, num2str(t_AOM/2),' ns',',','end_loop','\n']);
%         fprintf([OffSeq, num2str(t_CAMoff),' ns', '\n\n']);
%         
%         RefRunTime(i) = cycles * (tau(i) + t_AOM);             
%         fprintf([LaserCAMSeq, num2str(t_AOM/2),' ns',... 
%             ', ','loop',', ',num2str(cycles),...
%                '   //',num2str(RefRunTime(i)/1e6),' ms','\n']);               
%         fprintf([LaserCAMSeq, num2str(t_AOM/2),' ns',',','end_loop','\n']);
%         fprintf([OffSeq, num2str(t_CAMoff),' ns', '\n']);
%         continue
%     end
%     
    Laser = AOMcontrol * [zeros(1,tau(i)),zeros(1, t_blank * 2),ones(1,t_AOM)];
    MW = MWcontrol * [zeros(1, t_delay), zeros(1, t_blank),ones(1,tau(i)), ...
        zeros(1, t_blank),zeros(1,t_AOM-t_delay)];
    SPCM = SPCMcontrol * [zeros(1, t_delay),zeros(1,tau(i)),zeros(1, t_blank * 2),...
        ones(1,t_Readout),zeros(1, t_AOM-t_Readout*2-t_delay),ones(1,t_Readout)]; 
%     CAM = CAMcontrol * [ones(1,length(Sequence))];
%     Sequence = Sequence + CAM;
    Sequence = Laser + MW + SPCM;
    CutSeq = diff(Sequence);
    CutPoint = find(CutSeq ~= 0);
    t = diff([0,CutPoint,length(Sequence)]);
    RunTime(i) = sum(t) * cycles;
    bitseq = [CutPoint,length(Sequence)];
    
    if length(CutPoint) == 1
        RunTime(i) = cycles * (tau(i) + t_AOM);             
        fprintf([space,'0b',num2str(dec2bin(Head + Sequence(bitseq(2)))),...
            ', ', num2str(t(2) * cycles),' ns','   //', num2str(RunTime(i)/1e6),' ms','\n']);
    else
        for j  = 1:length(CutPoint) + 1
            bitcontrol{j} = [space,'0b',num2str(dec2bin(Head + Sequence(bitseq(j)))),', '];        
            switch j
                case 1
                    fprintf([bitcontrol{j}, num2str(t(j)),...
                        ' ns',', ','loop',', ',num2str(cycles),...
                        '   //',num2str(RunTime(i)/1e6),' ms','\n']);
                case length(CutPoint) + 1
                    fprintf([bitcontrol{j}, num2str(t(j)),...
                        ' ns',', ','end_loop','\n']);
                otherwise
                    fprintf([bitcontrol{j}, num2str(t(j)),' ns','\n']);
            end
        end
    end
end

TotalTime = (sum(RunTime) + t_CAMoff * points)/1e9/60;
WriteTime = sprintf('//Estimated Run Time = %.2f min\n', TotalTime);
fprintf(WriteTime);


