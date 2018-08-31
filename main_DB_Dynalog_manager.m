clc
clear
close all
%%
[FileName,PathName,FilterIndex] = uigetfile('*.dlg');
filelists = dir(fullfile(PathName, '*.dlg'));

Key   = 'RT';
for iter1 = 1: size(filelists, 1)
    filename_single = filelists(iter1).name;
    Index = strfind(filename_single, Key);
    RT_number = filename_single(19:23);
    folder_path = fullfile(PathName, num2str(RT_number));
    mkdir(folder_path)
    movefile(fullfile(PathName, filename_single), folder_path)
    clear filename_single RT_number folder_path
end