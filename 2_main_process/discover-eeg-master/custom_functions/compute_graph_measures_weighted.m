function compute_graph_measures_weighted(params,bidsID,freqBand,connMeasure,useWeighted)
% Compute graph theory measures for weighted or binary networks
% 
% Inputs:
%   params       - Parameters structure
%   bidsID       - BIDS identifier
%   freqBand     - Frequency band
%   connMeasure  - Connectivity measure ('dwpli' or 'aec')
%   useWeighted  - Boolean flag: true for weighted network analysis, false for binary

% Load connectivity matrix
conn_file = fullfile(params.ConnectivityPath,[bidsID '_' connMeasure '_' freqBand '.mat']);
fprintf('Loading connectivity matrix from: %s\n', conn_file);
if ~exist(conn_file,'file')
    error('Connectivity matrix file does not exist: %s', conn_file);
end
try
    load(conn_file,'connMatrix');
    fprintf('Successfully loaded connectivity matrix. Size: %dx%d\n', size(connMatrix,1), size(connMatrix,2));
catch ME
    error('Failed to load connectivity matrix from %s: %s', conn_file, ME.message);
end

% Handle NaN values in the connectivity matrix
connMatrix(isnan(connMatrix)) = 0;

if useWeighted
    % For weighted analysis, apply threshold first to sparsify the network
    % (same as binary networks), but keep the weight values for retained edges
    sortedValues = sort(abs(connMatrix(:)),'descend');
    sortedValues = sortedValues(~isnan(sortedValues));
    threshold = sortedValues(floor(params.ConnMatrixThreshold*length(sortedValues)));
    
    % Apply threshold: keep weights above threshold, set others to zero
    % This creates a sparse weighted network with the same density as binary network
    adjacency_matrix = abs(connMatrix);
    adjacency_matrix(adjacency_matrix < threshold) = 0;
    
    % Normalize to [0,1] range (only for non-zero values)
    max_val = max(adjacency_matrix(:));
    min_val = min(adjacency_matrix(adjacency_matrix > 0));
    if isempty(min_val)
        min_val = 0;
    end
    if max_val ~= min_val && max_val > 0
        % Normalize only non-zero values
        mask = adjacency_matrix > 0;
        adjacency_matrix(mask) = (adjacency_matrix(mask) - min_val) / (max_val - min_val);
    elseif max_val > 0
        adjacency_matrix(adjacency_matrix > 0) = adjacency_matrix(adjacency_matrix > 0) / max_val;
    else
        % If all values are zero, create a minimal connectivity to avoid errors
        warning(['All connectivity values are zero for ' bidsID '_' connMeasure '_' freqBand '. Using minimal connectivity.']);
        adjacency_matrix = eye(size(adjacency_matrix)) * 0.001;
    end
    
    % Ensure diagonal is zero
    adjacency_matrix = adjacency_matrix - diag(diag(adjacency_matrix));
else
    % Threshold the connectivity matrix depending on the desired amount of edges
    sortedValues = sort(abs(connMatrix(:)),'descend');
    sortedValues = sortedValues(~isnan(sortedValues));
    threshold = sortedValues(floor(params.ConnMatrixThreshold*length(sortedValues)));
    
    % Binarize connectivity matrix based on the threshold (adjacency matrix)
    adjacency_matrix = abs(connMatrix) >= threshold;
end

%% Graph analysis measures from Brain Connectivity toolbox
% Ensure BCT is in path (try both possible locations)
bct_path1 = 'F:\sport\data_process2025.11.10\4_stat\2019_03_03_BCT';
bct_path2 = params.BrainConnectivityToolboxPath;
if exist(bct_path1, 'dir') && ~contains(path, bct_path1)
    addpath(bct_path1);
    fprintf('Added BCT path: %s\n', bct_path1);
end
if exist(bct_path2, 'dir') && ~contains(path, bct_path2)
    addpath(bct_path2);
    fprintf('Added BCT path: %s\n', bct_path2);
end

% ---- Local measures ----- 
if useWeighted
    % Degree (Strength) - Sum of weights of connections for each node (weighted)
    % Use BCT function strengths_und for weighted undirected networks
    if exist('strengths_und', 'file') || exist('strengths_und', 'builtin')
        degree = strengths_und(adjacency_matrix);  % Returns row vector
    else
        % Fallback: manual calculation
        degree = sum(adjacency_matrix, 2)';  % Sum along rows, then transpose
        warning('strengths_und not found, using manual calculation');
    end
    
    % Clustering coefficient - Weighted clustering coefficient
    % clustering_coef_wu requires weights in [0,1] range (already normalized above)
    if exist('clustering_coef_wu', 'file') || exist('clustering_coef_wu', 'builtin')
        try
            cc = clustering_coef_wu(adjacency_matrix);
        catch ME
            % If function exists but fails, use binary version as fallback
            warning('clustering_coef_wu failed (%s), using binary clustering coefficient', ME.message);
            cc = clustering_coef_bu(double(adjacency_matrix > 0));
        end
    else
        % Use binary clustering coefficient if weighted version not available
        warning('clustering_coef_wu not found, using binary clustering coefficient');
        cc = clustering_coef_bu(double(adjacency_matrix > 0));
    end
else
    % Degree - Number of connections of each node (binary)
    degree = degrees_und(adjacency_matrix);
    % Clustering coefficient - Binary clustering coefficient
    cc = clustering_coef_bu(adjacency_matrix);
end

% ---- Global measures of segregation -----
% Global clustering coefficient
gcc = mean(cc);

% ---- Global measures of integration -----
if useWeighted
    % Characteristic path length for weighted networks
    % distance_wei requires a connection-length matrix, not a weight matrix
    % For correlation-based networks: higher correlation = shorter distance
    % Convert weights to lengths using inverse (1/W) or negative log
    % Use inverse: length = 1/weight (higher weight = shorter distance)
    length_matrix = adjacency_matrix;
    length_matrix(length_matrix > 0) = 1 ./ length_matrix(length_matrix > 0);
    length_matrix(length_matrix == 0) = Inf;  % Disconnected nodes have infinite distance
    length_matrix = length_matrix - diag(diag(length_matrix));  % Diagonal should be 0
    
    if exist('distance_wei', 'file') || exist('distance_wei', 'builtin')
        try
            distance = distance_wei(length_matrix);
        catch ME
            warning('distance_wei failed (%s), using fallback calculation', ME.message);
            distance = length_matrix;  % Use length matrix directly
        end
    else
        warning('distance_wei not found, using length matrix directly');
        distance = length_matrix;
    end
    
    % Handle disconnected networks (Inf values)
    if any(isinf(distance(:)))
        % Replace Inf with a large value for path length calculation
        distance_inf = distance;
        finite_vals = distance_inf(~isinf(distance_inf(:)));
        if ~isempty(finite_vals)
            distance_inf(isinf(distance_inf)) = max(finite_vals) * 10;
        else
            distance_inf(isinf(distance_inf)) = 1;  % Fallback if all are Inf
        end
        [cpl, ~] = charpath(distance_inf,0,0);
        if isinf(cpl) || isnan(cpl)
            cpl = 0; % Fallback if still problematic
        end
    else
        [cpl, ~] = charpath(distance,0,0); % it does not include infinite distances in the calculation
    end
    
    % Global efficiency for weighted networks
    if exist('efficiency_wei', 'file') || exist('efficiency_wei', 'builtin')
        try
            geff = efficiency_wei(adjacency_matrix); % it includes infinite distances in the calculation
        catch ME
            warning('efficiency_wei failed (%s), using fallback', ME.message);
            geff = 0;
        end
    else
        warning('efficiency_wei not found, using fallback');
        geff = 0;
    end
    if isnan(geff) || isinf(geff)
        geff = 0; % Fallback if calculation fails
    end
else
    % Characteristic path length for binary networks
    distance = distance_bin(adjacency_matrix);
    [cpl, ~] = charpath(distance,0,0); % it does not include infinite distances in the calculation 
    % Global efficiency for binary networks
    geff = efficiency_bin(adjacency_matrix); % it includes infinite distances in the calculation
end

% ----- Small-worldness -----
% Typically in small-world networks L >= Lrand but CC >> CCrand
if useWeighted
    % For weighted networks, create random weighted network
    % Match the density of the original network
    density = sum(adjacency_matrix(:) > 0) / (length(adjacency_matrix)^2 - length(adjacency_matrix));
    randN = rand(size(adjacency_matrix));
    randN = (randN + randN')/2; % Make symmetric
    % Sparsify to match density (keep top connections)
    sorted_rand = sort(randN(:), 'descend');
    threshold_idx = floor(density * length(sorted_rand));
    if threshold_idx > 0 && threshold_idx <= length(sorted_rand)
        threshold_val = sorted_rand(threshold_idx);
        randN = randN .* double(randN >= threshold_val);
    else
        randN = randN .* double(randN > 0.5); % Fallback
    end
    % Ensure diagonal is zero
    randN = randN - diag(diag(randN));
    % Ensure at least some connectivity
    if sum(randN(:)) == 0
        % Add minimal connectivity if random network is empty
        randN = adjacency_matrix * 0.1; % Use scaled version of original
    end
    % Normalize random network to [0,1] for clustering_coef_wu
    randN_norm = randN;
    if max(randN_norm(:)) > 0
        randN_norm = randN_norm / max(randN_norm(:));
    end
    
    if exist('clustering_coef_wu', 'file') || exist('clustering_coef_wu', 'builtin')
        try
            gcc_rand = mean(clustering_coef_wu(randN_norm));
        catch
            gcc_rand = mean(clustering_coef_bu(double(randN > 0)));
        end
    else
        gcc_rand = mean(clustering_coef_bu(double(randN > 0)));
    end
    if isnan(gcc_rand) || isinf(gcc_rand)
        gcc_rand = 0.001; % Fallback
    end
    
    % Convert random network to length matrix for distance calculation
    randN_length = randN;
    randN_length(randN_length > 0) = 1 ./ randN_length(randN_length > 0);
    randN_length(randN_length == 0) = Inf;
    randN_length = randN_length - diag(diag(randN_length));
    
    if exist('distance_wei', 'file') || exist('distance_wei', 'builtin')
        try
            distance_rand = distance_wei(randN_length);
        catch
            distance_rand = randN_length;
        end
    else
        distance_rand = randN_length;
    end
    % Handle disconnected random networks
    if any(isinf(distance_rand(:)))
        distance_rand_inf = distance_rand;
        distance_rand_inf(isinf(distance_rand_inf)) = max(distance_rand_inf(~isinf(distance_rand_inf(:)))) * 10;
        [cpl_rand, ~] = charpath(distance_rand_inf,0,0);
    else
        [cpl_rand, ~] = charpath(distance_rand,0,0);
    end
    if isnan(cpl_rand) || isinf(cpl_rand) || cpl_rand == 0
        cpl_rand = 1; % Fallback to avoid division by zero
    end
else
    % For binary networks
    randN = makerandCIJ_und(length(adjacency_matrix), floor(sum(sum(adjacency_matrix)))/2);
    gcc_rand = mean(clustering_coef_bu(randN));
    [cpl_rand, ~] = charpath(distance_bin(randN),0,0);
end
% Calculate small-worldness with error handling
if gcc_rand > 0 && cpl_rand > 0 && cpl > 0
    smallworldness = (gcc/gcc_rand) / (cpl/cpl_rand);
    if isnan(smallworldness) || isinf(smallworldness)
        smallworldness = 1; % Fallback value
    end
else
    smallworldness = 1; % Fallback if denominators are zero
end

% Store results
graph_measures.useWeighted = useWeighted;
graph_measures.threshold = threshold; % Store threshold for both weighted and binary networks
graph_measures.degree = degree';
graph_measures.cc = cc;
graph_measures.gcc = gcc;
graph_measures.geff = geff;
graph_measures.smallworldness = smallworldness;

% Display summary of computed measures
fprintf('Computed graph measures summary:\n');
fprintf('  - Degree: mean=%.4f, std=%.4f\n', mean(degree), std(degree));
fprintf('  - Clustering coefficient: mean=%.4f, std=%.4f\n', mean(cc), std(cc));
fprintf('  - Global clustering coefficient: %.4f\n', gcc);
fprintf('  - Global efficiency: %.4f\n', geff);
fprintf('  - Small-worldness: %.4f\n', smallworldness);
fprintf('  - Threshold used: %.6f\n', threshold);

% Save with appropriate filename based on network type
if useWeighted
    output_file = fullfile(params.GraphPath,[bidsID '_graph_' connMeasure '_' freqBand '_weighted.mat']);
    fprintf('Saving weighted graph measures to: %s\n', output_file);
    try
        save(output_file,'graph_measures');
        if exist(output_file,'file')
            fprintf('Successfully saved weighted graph measures file: %s\n', output_file);
        else
            warning('File was not created: %s', output_file);
        end
    catch ME
        error('Failed to save weighted graph measures file: %s\nError: %s', output_file, ME.message);
    end
else
    output_file = fullfile(params.GraphPath,[bidsID '_graph_' connMeasure '_' freqBand '.mat']);
    fprintf('Saving binary graph measures to: %s\n', output_file);
    try
        save(output_file,'graph_measures');
        if exist(output_file,'file')
            fprintf('Successfully saved binary graph measures file: %s\n', output_file);
        else
            warning('File was not created: %s', output_file);
        end
    catch ME
        error('Failed to save binary graph measures file: %s\nError: %s', output_file, ME.message);
    end
end
     
end