%George Moore 

clc
close all
clear all
resetit = 0;
cla reset;
s = serial('/dev/cu.usbserial-1420','BaudRate',9600);
fopen(s);
fprintf(s,'*IDN?');
i = 1;
x = 0; 
beats = 0;
bpm = 0;
count = 0;
end_time = 0;
quitbutton = uicontrol('style','pushbutton',...
   'string','Close', ...
   'fontsize',12, ...
   'position',[450,10,50,20], ...
   'callback','quitit=1;fclose(s);delete(gcf);');
restbutton = uicontrol('style','pushbutton',...
   'string','Reset', ...
   'fontsize',12, ...
   'position',[100,10,50,20], ...
   'callback','resetit=1;');
quitit = 0;

%Getting serial data from Arduino
while (quitit == 0)
    x = x + 1;
    ecg(i) = str2double(fscanf(s));
    i = i + 1;
    plot(ecg)
    axis ([0 1500 0 600])
    grid on
    pause(0.1)
    time = (1:numel(ecg))/200;
    %disp(time); 
       while (resetit == 1)
           delete(ecg);
           resetit = 0;
           
       end
       
        
end
%Once user clicks end button
delete(s);
[peaks_2,pos_peaks] = findpeaks(ecg,'MINPEAKDISTANCE',100,'MINPEAKHEIGHT',355);
count = numel(findpeaks(ecg,'MINPEAKDISTANCE',100,'MINPEAKHEIGHT',355));
end_time = (0.3 * i) / 60;
V_bpm = (60 / end_time) * count;
disp(V_bpm);


bpm_values = zeros(1,10);
bpm_values(pos_peaks) = bpm;

plot(time,ecg,'b',pos_peaks/200,(peaks_2),'ro')

LineH = get(gca, 'Children');
x = get(LineH, 'XData');
y = get(LineH, 'YData');


%R-wave Plot
subplot(211)
plot(time,ecg,'b',pos_peaks/200,(peaks_2),'ro')
legend('ECG Signal', 'R-wave')
grid on
axis tight
ylabel ('Serial Data','fontsize',16)



%P-Wave Plot
subplot(212)
peaks_1 = ecg<350;

[pks1,p1_peaks] = findpeaks(ecg,'MINPEAKHEIGHT',320, 'MinPeakDistance',10);
[pks2,p2_peaks] = findpeaks(ecg,'MINPEAKHEIGHT',355, 'MinPeakDistance',10);
[C, ia] = setdiff(p1_peaks, p2_peaks, 'stable');
MidPks = [pks1(ia); p1_peaks(ia)];

[peaks_2,pos_peaks] = findpeaks(ecg,'MINPEAKDISTANCE',20,'MINPEAKHEIGHT',315, 'MinPeakProminence',1);


% P-wave peaks between 335 and 355
locs_Pwave = pos_peaks(ecg(pos_peaks)>335 & ecg(pos_peaks)<355);
count_2 = numel(pos_peaks(ecg(pos_peaks)>335 & ecg(pos_peaks)<355));
end_time = (0.3 * i) / 60;
A_bpm = (60 / end_time) * count_2;
disp(A_bpm);
plot(time,ecg,'b')
%hold on

plot(time,ecg,'b',locs_Pwave/200,(ecg(locs_Pwave)),'rs','MarkerFaceColor','g');
legend('ECG Signal','P-wave');

axis tight
grid on
axis tight

ylabel ('Serial Data','fontsize',16)
xlabel ('Time (seconds)','fontsize',16)


%Interpretation boxes
bpmtext = uicontrol('style', 'text',...
    'string', ['BPM: '],...
    'fontsize', 14,...
    'position', [80, 08, 155, 20]);

set(bpmtext, 'string', ['Vent BPM: ',...
                            num2str(V_bpm,4)]);
                      
sinus = 'Normal Sinus Rhythm';
sinus_brady = 'Sinus bradycardia';
sinus_tach = 'Sinus tachycardia';
nonconductive = 'Limited (not every P-wave conducts a QRS)';

%NSR code
if (count == count_2)
    rhytext = uicontrol('style', 'text',...
    'string', [''],...
    'fontsize', 14,...
    'position', [300,08,200,20]);
if (V_bpm >= 60 && V_bpm <=100)
    
    set(rhytext, 'string', ['Rhythm: ', ... 
    (sinus)]);
else
    %Bradycardia
    if (V_bpm <= 59)
    
    set(rhytext, 'string', ['Rhythm: ', ... 
    (sinus_brady)]);
    else
        %Tachycardia
        if (V_bpm >= 100)
    
    set(rhytext, 'string', ['Rhythm: ', ... 
    (sinus_tach)]);

    end
    end
end
else
    %Limited interpretation
    if (count ~= count_2)
        rhytext = uicontrol('style', 'text',...
    'string', [''],...
    'fontsize', 14,...
    'position', [350,08,315,20]);
        set(rhytext, 'string', ['Rhythm: ', ... 
    (nonconductive)]);
atrial_text = uicontrol('style', 'text',...
    'string', [''],...
    'fontsize', 14,...
    'position', [200, 08, 100, 20]);
        set(atrial_text, 'string', ['Atrial BPM: ', ... 
    num2str(A_bpm,4)]);
    end
end

