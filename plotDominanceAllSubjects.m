% This script generates one measure of sensory dominance and one of behavioural
% quality for each session since a subject began dominance training.

% check for new recordings
csv.checkForNewPinkRigRecordings('expDate', 2);
% define all subjects
subjects = {...
    'AV043', ...
    'GB001', ...
    'GB002', ...
    'GB004', ...
    'GB008', ...
    'GB010', ...
    'GB011', ...
    'GB012', ...
    'AV061', ...
    'AV062', ...
    'AV064'};

% and the dates they began dominance training
startDates = {...
    '2023-08-23:', ... %AV043
    '2023-08-04:', ... %GB001
    '2023-08-04:', ... %GB002
    '2023-08-04:', ... %GB004
    '2024-01-26:', ... %GB008
    '2024-02-09:', ... %GB010
    '2024-04-12:', ... %GB011
    '2024-04-26:', ... %GB012
    '2025-09-10:', ... %AV061
    '2025-09-10:', ... %AV062
    '2025-10-24:'}; %AV064

% and the session in which a new sensory block starts
blockStarts = {...
    [1, 36, 44, 64, 69, 79, 85, 100, 115], ... %AV043
    [1, 23, 39, 49, 55, 69, 79], ... %GB001
    [1, 23, 39, 49, 54, 63, 70, 82, 87, 99, 114, 123], ... %GB002
    [1, 23, 39, 49, 56, 71, 79, 91, 103], ... %GB004
    [1, 9, 21, 25], ... %GB008
    [1, 8, 15, 23, 30, 40], ... %GB010
    [1, 8, 11, 21, 23], ... %GB011
    [1, 13, 20, 33, 45, 61, 83, 103, 112], ... %GB012
    [1, 12, 22, 40, 50, 69, 78, 96, 107, 124, 132, 140], ... %AV061
    [1, 9, 18, 26, 42, 52, 67, 79, 95, 110, 126, 139], ... %AV062
    [1, 7, 13, 25, 32, 45, 53]}; %AV064

% and the type of stimulus corresponding with that block (auditory = 1; visual = -1)
blockTypes = {...
    [-1, 1, -1, 1, -1, 1, -1, 1, -1], ... %AV043
    [-1, 1, -1, 1, -1, 1, -1], ... %GB001
    [-1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1], ... %GB002
    [-1, 1, -1, 1, -1, 1, -1, 1, -1], ... %GB004
    [1, -1, 1, -1], ... %GB008
    [-1, 1, -1, 1, -1, 1], ... %GB010
    [-1, 1, -1, 1, -1], ... %GB011
    [-1, 1, -1, 1, -1, 1, -1, 1, -1], ... %GB012
    [-1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1], ... %AV061
    [1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1], ... %AV062
    [-1, 1, -1, 1, -1, 1, -1]}; %AV064

for i = 1:length(subjects)
    subject = subjects{i};
    
    % retrieve the date the current subject started dominance training...
    startDate = startDates{i};
    % and the session numbers in which the dominance was switched for the subject...
    blockStart = blockStarts{i};
    numBlocks = length(blockStart);
    % and the type of dominance to which the subject was switched
    blockType = blockTypes{i};

    % define the date range to loop through
    % If dateRange is left as [startDate, endDate] 
    % all sessions up to the present date are run
    todayDate = datestr(today, 'yyyy-mm-dd');
    endDate = todayDate;
    dateRange = [startDate, endDate];
    exp = csv.queryExp(subject=subject,expDate=dateRange,expDef='t');
    exp = exp(cell2mat(cellfun(@(x) str2double(x), exp.expDuration, 'uni', 0)) > 600, :);

    numSessions = height(exp); 
    quality = zeros(numSessions, 1);
    dominance = zeros(numSessions, 1);
    bias = zeros(numSessions, 1);

    for j = 1:numSessions
        currentDay = exp(j,:);
        currentPlot = plts.behaviour.boxPlots(currentDay, noPlot=1);
        currentPercents = currentPlot{1,1}.plotData; 
        % coherentRight, trials in which both audio and visual stimuli are on the right
        % coherentRight = currentPercents(end,end);
        % coherentLeft, trials in which both audio and visual stimuli are on the left
        % coherentLeft = currentPercents(1,1);
        % conflictA, trials in which audio stimuli are on the right and visual stimuli are on the left
        conflictA = mean(currentPercents(end,[1 2]));
        % conflictB, trials in which audio stimuli are on the left and visual stimuli are on the right
        conflictB = mean(currentPercents(1, [end-1 end]));
        % quality, scored −1 to 1; accuracy on easiest coherent multisensory trials
        % a score of <0.9 indicates that this session's data are not reliable for evaluating dominance
        % quality(j) = coherentRight - coherentLeft;
        % dominance, scored −1 to 1; evaluation of a subject's sensory dominance
        % a score of −1 would indicate complete visual dominance
        % a score of 1 would indicate complete auditory dominance
        dominance(j) = conflictA - conflictB;
        % calculate the percentage of right turns
        bias(j) = ((mean(nanmean(currentPercents)))-0.5)*2;

    end

    blockEnds = {...
        [36, 44, 64, 69, 79, 85, 100, 115, numSessions], ... %AV043
        [23, 39, 49, 55, 69, 79, numSessions], ... %GB001
        [23, 39, 49, 54, 63, 70, 82, 87, 99, 114, 123, numSessions],  ... %GB002
        [23, 39, 49, 56, 71, 79, 91, 103, numSessions], ... %GB004
        [9, 21, 25, numSessions], ... %GB008
        [8, 15, 23, 30, 40, numSessions], ... %GB010
        [8, 11, 21, 23, numSessions], ... %GB011
        [13, 20, 33, 45, 61, 83, 103, 112, numSessions], ... %GB012
        [12, 22, 40, 50, 69, 78, 96, 107, 124, 132, 140, numSessions], ... %AV061
        [9, 18, 26, 42, 52, 67, 79, 95, 110, 126, 139, numSessions], ... %AV062
        [7, 13, 25, 32, 45, 53, numSessions]}; %AV064}; %GB012
    blockEnd = blockEnds{i};
    
    figure;
    hold on;
    % plot alternating bg colours for aud and vis training blocks
    % pink bg for audio training, blue bg for visual training
    for k = 1:numBlocks
        if blockType(k) == 1
            x = [blockStart(k), blockEnd(k), blockEnd(k), blockStart(k)];
            y = [-1, -1, 1, 1];
            % patch(x,y,'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            patch(x,y,'r', 'FaceColor', '#FFC0D9', 'FaceAlpha', 0.8, 'EdgeColor', 'none');
        elseif blockType(k) == -1
            x = [blockStart(k), blockEnd(k), blockEnd(k), blockStart(k)];
            y = [-1, -1, 1, 1];
            % patch(x,y,'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            patch(x,y,'b', 'FaceColor', '#7BD3EA', 'FaceAlpha', 0.8, 'EdgeColor', 'none');
        end
    end

    % plot quality and dominance and right turn percentage
    % plot(quality, 'DisplayName', 'Quality');
    plot(dominance, 'k', 'Marker', '.', 'DisplayName', 'Dominance');
    plot(bias, 'r', 'Marker', '.', 'DisplayName', 'Bias');

    % plot horizontal lines for thresholds of quality (0.9), 
    % dominance (−0.6, 0.6) and a line at 0 unless you're a psychopath
    yline(0.6);
    yline(0);
    yline(-0.6);
    % yline(0.9);
    xlim([1 numSessions])
    hold off;
    title(sprintf('Mouse: %s', subject));

    % generate the present day's plots
    plts.behaviour.boxPlots(subject=subject,expDate='last1');
    plts.behaviour.glmFit(subject=subject,expDate='last1');
end