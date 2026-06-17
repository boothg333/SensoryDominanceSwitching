%% Check for new recordings beforehand with...
% csv.checkForNewPinkRigRecordings('expDate', 2);
% define all subjects
subjects = {'AV060'};
% and the dates they began dominance training
startDates = {'2025-11-21:'};
% and the session in which a new sensory block starts
blockStarts = {[1, 9, 40, 57]};
% and the type of stimulus corresponding with that block (auditory = 1; visual = -1)
blockTypes = {[1, -1, 1, -1]};

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
    % endDate = '2026-29-04'; % for checking whether for checking 
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
        if currentPlot{1}.totTrials > 150
            currentPercents = currentPlot{1,1}.plotData;
            % coherentRight, trials in which both audio and visual stimuli are on the right
            coherentRight = currentPercents(end,end);
            % coherentLeft, trials in which both audio and visual stimuli are on the left
            coherentLeft = currentPercents(1,1);
            % conflictA, trials in which audio stimuli are on the right and visual stimuli are on the left
            conflictA = mean(currentPercents(end,[1 2]));
            % conflictB, trials in which audio stimuli are on the left and visual stimuli are on the right
            conflictB = mean(currentPercents(1, [end-1 end]));
            % quality, scored −1 to 1; accuracy on easiest coherent multisensory trials
            % a score of <0.9 indicates that this session's data are not reliable for evaluating dominance
            quality(j) = coherentRight - coherentLeft;
            % dominance, scored −1 to 1; evaluation of a subject's sensory dominance
            % a score of −1 would indicate complete visual dominance
            % a score of 1 would indicate complete auditory dominance
            dominance(j) = conflictA - conflictB;
            % calculate the percentage of right turns
            bias(j) = ((mean(nanmean(currentPercents)))-0.5)*2;
        else
            quality(j) = NaN;
            dominance(j) = NaN;
            bias(j) = NaN;
        end

    end

    blockEnds = {[9, 40, 57, numSessions]};
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
    plot(quality, 'g', 'LineWidth', 2, 'Marker', '.', 'DisplayName', 'Quality');
    plot(dominance, 'k','LineWidth', 2,  'Marker', '.', 'DisplayName', 'Dominance');
    plot(bias, 'r', 'LineWidth', 2, 'Marker', '.', 'DisplayName', 'Bias');

    % plot horizontal lines for thresholds of quality (0.9), 
    % dominance (−0.6, 0.6) and a line at 0 unless you're a psychopath
    yline(0.6, '-', 'AudioThreshold');
    yline(0);
    yline(-0.6, '-', 'VisualThreshold');
    yline(0.9, '--k', 'QualityThreshold');
    % xline(32.5, '--r', 'MouseImplanted');
    xlim([1 numSessions])
    hold off;
    title(sprintf('Mouse: %s', subject));

    % generate the present day's plots
    plts.behaviour.boxPlots(subject=subject,expDate='last1');
    % plts.behaviour.glmFit(subject=subject,expDate='last1');
end