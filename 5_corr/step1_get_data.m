clear all;

% % Add toolboxes and functions
% eeglab_path = 'D:\Matlab_EEGtoolbox\eeglab2024.0';
% run(fullfile(eeglab_path,'eeglab.m'));
% addpath D:\Matlab_EEGtoolbox\fieldtrip-20240701
% ft_defaults
addpath(genpath('E:\1NWNU\Sport_dep\data_process2025.11.10\4_stat\bayesFactor-master'));
run('installBayesFactor.m')

results_path = 'E:\1NWNU\Sport_dep\data_process2025.11.10\5_corr';

% Load atlas for plotting the connectivity matrices
n_sources = 100;
atlas_path = 'E:\1NWNU\Sport_dep\data_process2025.11.10\2_main_process\discover-eeg-master\parcellations\Schaefer2018_100Parcels_7Networks_order_FSLMNI152_1mm.Centroid_RAS.csv';
atlas100 = readtable(atlas_path);


freqBands = {'theta','alpha','beta','gamma'};
connMeas = {'dwpli','aec'};
networks = {'Vis','SomMot','DorsAttn','SalVentAttn','Limbic','Cont','Default'};


%% GRAPH MEASURES
graph_path_ctr = 'E:\1NWNU\Sport_dep\data_process2025.11.10\3_processed_data_results\control\0.3\EEG_features\graph_measures';
graph_path_sd = 'E:\1NWNU\Sport_dep\data_process2025.11.10\3_processed_data_results\sport_dependence\0.3\EEG_features\graph_measures';

for iConnMeas = 1: length(connMeas)

    % List matrices
    meas = connMeas{iConnMeas};
    graph_files_ctr = dir(fullfile(graph_path_ctr,['*_' meas '_*.mat']));
    graph_files_sd = dir(fullfile(graph_path_sd,['*_' meas '_*.mat']));
    
    for iBand=1:length(freqBands)
        fBand = freqBands{iBand};

        graph_files_band_ctr = graph_files_ctr(contains({graph_files_ctr.name},fBand));
        graph_files_band_sd = graph_files_sd(contains({graph_files_sd.name},fBand));

        subject_graph_ctr = cellfun(@(x) regexp(x,['.*(?=_graph_' meas '_*)'],'match','lineanchors'),{graph_files_band_ctr.name});
        subject_graph_sd = cellfun(@(x) regexp(x,['.*(?=_graph_' meas '_*)'],'match','lineanchors'),{graph_files_band_sd.name});

        % Load graph measures from the control and sport_dep group
        
        ctr_degree = nan(length(subject_graph_ctr),n_sources);
        ctr_cc = nan(length(subject_graph_ctr),n_sources);
        ctr_gcc = nan(1,length(subject_graph_ctr));
        ctr_geff = nan(1,length(subject_graph_ctr));
        ctr_s = nan(1,length(subject_graph_ctr));

        sd_degree = nan(length(subject_graph_sd),n_sources);
        sd_cc = nan(length(subject_graph_sd),n_sources);
        sd_gcc = nan(1,length(subject_graph_sd));
        sd_geff = nan(1,length(subject_graph_sd));
        sd_s = nan(1,length(subject_graph_sd));
        
        for i=1:length(subject_graph_ctr)
            try
                load(fullfile(graph_files_band_ctr(i).folder,graph_files_band_ctr(i).name));
            catch
                error(['cannot load data from ' graph_files_band_ctr(i).name])
            end

            ctr_degree(i,:) = graph_measures.degree;
            ctr_cc(i,:) = graph_measures.cc;
            ctr_gcc(i) = graph_measures.gcc;
            ctr_geff(i) = graph_measures.geff;
            ctr_s(i) = graph_measures.smallworldness;
        end
        
        for j=1:length(subject_graph_sd)
            try
                load(fullfile(graph_files_band_sd(j).folder,graph_files_band_sd(j).name));
            catch
                error(['cannot load data from ' graph_files_band_sd(j).name])
            end

            sd_degree(j,:) = graph_measures.degree;
            sd_cc(j,:) = graph_measures.cc;
            sd_gcc(j) = graph_measures.gcc;
            sd_geff(j) = graph_measures.geff;
            sd_s(j) = graph_measures.smallworldness;
        end
        
        % Global measures data
        global_data.gcc(iBand,:) = {ctr_gcc,sd_gcc};
        global_data.geff(iBand,:) = {ctr_geff,sd_geff};
        global_data.s(iBand,:) = {ctr_s,sd_s};
       
        % Local measures data
        local_data.degree(iBand,:) = {ctr_degree,sd_degree};
        local_data.cc(iBand,:) = {ctr_cc,sd_cc};
        
    end

    save(fullfile(results_path,['global_data_graph_' meas '.mat']),'global_data');
    save(fullfile(results_path,['local_data_graph_' meas '.mat']),'local_data');


end

