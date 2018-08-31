clc
clear
close all
%%
[LogInfo_FileName,LogInfo_PathName,LogInfo_FilterIndex] = uigetfile('*.xlsx','MLC log information');
DynalogInfo = readtable(fullfile(LogInfo_PathName, LogInfo_FileName));
%
%
%% Load Sub-directory of DynalogDB
addpath('LB_Dynalog')
dynConstants
%
pathFolder = uigetdir;
d = dir(pathFolder);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
nameFolds(1:2,:) = [];
%%
pathFolder_summary = fullfile(pathFolder, 'Summary')
mkdir(pathFolder_summary)
%%
h = waitbar(0,'Please wait...');
steps = size(nameFolds,1);
Modulation_index_total= []
MLC_position_error_total = []
total_counter = 0;
for folder_iter = 1: size(nameFolds,1)
    folder_single = fullfile(pathFolder, nameFolds{folder_iter});
    % [BankAFileName,BankAPathName,BankAFilterIndex] = uigetfile('a*.dlg','Select Dynalog file (A Bank)');
    BankAPathName = folder_single;
    bankA_list = dir(fullfile(BankAPathName, 'a*.dlg'));
    if(isempty(bankA_list))
        continue
    end
    MCSv_list = [];
    MLC_Error_list = [];
    Summary_per_patient = {};
    Summary_per_patient{1,1} = 'Filename of Dynalog';
    Summary_per_patient{1,2} = 'Modulation index';
    Summary_per_patient{1,3} = 'MLC error';
    
    for iter2 = 1 : size(bankA_list, 1)
        BankAFileName = bankA_list(iter2).name
        bankA = dynRead(fullfile(BankAPathName,BankAFileName));
        BankAFileName(1) = [];
        bankBName = strcat('B', BankAFileName);
        bankB = dynRead(fullfile(BankAPathName,bankBName));
        %
        %
        %
        bankA_pos = bankA.actualPosition;
        bankB_pos = bankB.actualPosition;
        numLeaves = bankA.numLeaves;
        numFraction = bankA.numFractions;
        %
        %
        % remove Error-contained Dynalog.
        if size(bankA_pos,1) - size(bankB_pos,1) ~= 0
            disp('pass')
            continue
        end
        
        if size(bankA_pos,2) - size(bankB_pos,2) ~= 0
            disp('pass')
            continue
        end
        %
        % Feature extraction #1 AAV_max
        [AAVPlan, AAVActual] = dynAAV(bankA, bankB) ;
        AAVActual_per_fraction = [];
        for iter1 = 1: size(AAVActual,3)
            AAVActual_per_fraction(iter1) = sum(sum(AAVActual(:,:,iter1)));
        end
        AAV_max = max(AAVActual_per_fraction);
        %
        %
        %
        %
        %
        %
        %
        % Calculated MSCv
        number_of_control_point = size(bankA_pos, 1);
        MCSv = 0;
        %
        for iter1 = 1: numFraction-1
            cp_index = iter1;
            %
            LSV_component = (cal_LSV_cp_v3( cp_index, bankA_pos, bankB_pos) + ...
                cal_LSV_cp_v3( cp_index+1, bankA_pos, bankB_pos))/2;
            %
            AAV_component = (cal_AAV_cp_v2( cp_index, AAVActual, AAV_max) + ...
                cal_AAV_cp_v2(cp_index+1, AAVActual, AAV_max))/2;
            %
            MU_component_bw_cp_norm = diff(bankA.doseFraction)./max(bankA.doseFraction);
            MU_component_bw_cp_norm = abs(MU_component_bw_cp_norm);
            MU_component = MU_component_bw_cp_norm(cp_index);
            %         MU_component_bw_cp_B = diff(bankB.doseFraction)
            
            MCSv = MCSv + (AAV_component * LSV_component * MU_component);
            
            MCSv_tt(iter1) = (AAV_component * LSV_component * MU_component);
            AAV_component_tt(iter1) = AAV_component;
            LSV_component_tt(iter1) = LSV_component;
            MU_component(iter1) = MU_component;
        end
        
        MCSv_list(iter2) = MCSv;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        MLC_Error_bankA = abs(bankA.actualPosition - bankA.planPosition);
        MLC_Error_bankB = abs(bankB.actualPosition - bankB.planPosition);
        MLC_Error_Sum_Vec = [MLC_Error_bankA ; MLC_Error_bankB];
        MLC_Error_avg = mean(MLC_Error_Sum_Vec(:));
        MLC_Error_list(iter2) = MLC_Error_avg
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Summary_per_patient{iter2+1,2} = MCSv;
        Summary_per_patient{iter2+1,3} = MLC_Error_avg;
        %
        %
        total_counter = total_counter+ 1
        Modulation_index_total(total_counter) = MCSv;
        MLC_position_error_total(total_counter) = MLC_Error_avg;

        
        
        clear MLC_Error_bankA MLC_Error_bankB MLC_Error_Sum_Vec MLC_Error_avg MCSv MLC_Error_avg AAV_max AAVActual AAVPlan
    end
    save_filename_Summary_per_patient = ['Summary_ModulationIndex_MLCError_RT' nameFolds{folder_iter} '.xlsx'];
    save_xlsxname_Summary_per_patient = fullfile(pathFolder_summary, save_filename_Summary_per_patient);
    xlswrite(save_xlsxname_Summary_per_patient,Summary_per_patient);
    clear Summary_per_patient
    %
    figure_debug = false;
    if (figure_debug)
        figure, bar(MCSv_list), title('Modulation index over Fx'), xlabel('Fx'), ylabel('Modulation index')
        figure, bar(MLC_Error_list), title('MLC error over Fx'), xlabel('Fx'), ylabel('MLC error')
    end
    
    mean_MCSv_list = mean(MCSv_list);
    mean_MLC_Error_list = mean(MLC_Error_list);
    summary_all_dynalog{folder_iter,1} = nameFolds{folder_iter};
    summary_all_dynalog{folder_iter,2} = mean_MCSv_list;
    summary_all_dynalog{folder_iter,3} = mean_MLC_Error_list;
    waitbar(folder_iter / steps)
end
close(h)
%%
sz_Summary_cell = size(summary_all_dynalog,1);
sz_DynalogInfo_RTID = size(DynalogInfo.RTID,1);
for iter_find = 1:  sz_Summary_cell
    [row,col] = find(str2num(summary_all_dynalog{iter_find, 1}) == DynalogInfo.RTID);
    if isempty(row)
        continue
    end
    sites = DynalogInfo.SITE(row);
    sites = sites{1};
    C = strsplit(sites,' ');
    site = C{1};
    summary_all_dynalog{iter_find,4} = site;
end
%%
SitesName = summary_all_dynalog(:,4)
SitesName = SitesName(~any(cellfun('isempty', SitesName), 2), :);
for iter_string = 1: size(SitesName,1)
    old = SitesName{iter_string};
    new = strrep(old,',','');
    SitesName{iter_string} = new;
end
SitesName_Unique = unique(SitesName);
%
unique_site_summary = []
summary_per_unique_site = []
size_SitesName_Unique = size(SitesName_Unique,1)
unique_counter = 0;
for iter_unique = 1: size_SitesName_Unique
    Sites_selected = SitesName_Unique{iter_unique}
    Sites_selected_Modulation_index = []
    Sites_seleected_MLC_error = []
    counter = 0
    for iter10 = 1: size(summary_all_dynalog, 1)
        target_sites = summary_all_dynalog{iter10,4}
        if (strncmpi(Sites_selected,target_sites,4))
            counter = counter+1
            Sites_selected_Modulation_index(counter) = summary_all_dynalog{iter10, 2}
            Sites_seleected_MLC_error(counter) = summary_all_dynalog{iter10, 3}
            unique_counter = unique_counter + 1;
        end
    end
    summary_per_unique_site(iter_unique, 1) = mean(Sites_selected_Modulation_index)
    summary_per_unique_site(iter_unique, 2) = mean(Sites_seleected_MLC_error)
    summary_per_unique_site(iter_unique, 3) = unique_counter;
    unique_counter = 0
    
end
%
%% SAVE 

Summary_Head_3 = {'Site', 'Modulation index', 'MLC position error at isocenter [mm]'}
Summary_Head_4 = {'RT Number', 'Modulation index', 'MLC position error at isocenter [mm]', 'Sites'}
summary_per_unique_site = [Summary_Head_3 ; num2cell(summary_per_unique_site)];
summary_all_dynalog = [Summary_Head_4; summary_all_dynalog];

save_filname_per_site = '00_Summary_per_site.xlsx';
save_filename_all_dynalog = '01_Summary_all_dynalog.xlsx';
xlswrite(fullfile(pathFolder_summary, save_filename_Summary_per_patient), summary_per_unique_site)
xlswrite(fullfile(pathFolder_summary, save_filename_all_dynalog), summary_all_dynalog)
%%
MCSv_list(MCSv_list==0) = []
figure, histogram(MCSv_list), xlim([0 , 1]), grid on,
xlabel('Modulation index')
ylabel('Frequency')
title('Analysis Dynalog as modulation index')
