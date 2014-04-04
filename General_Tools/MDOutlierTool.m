% Remove outliers from raw data using Mahalanobis Distance
% Stephen Foldes
% 05-19-10
%
% This uses Mahalanobis Distance (MD) to remove noisy data. MD uses correlation between all channels.
% Possible to use mahal() matlab function, but returns memory errors for large data sets
% This method can be used to determine if a trial is aberent
%
% 
% INPUT
% raw_data = (samples x channels)
% outlier_thres = optional. Can input a number of standard deviations to remove. If [], then it you can try different cutoffs
%                 if vector is input, then each number is a consecutive STD to remove during iteration
% 
% OUTPUT
% clean_idx = indices that are concidered clean (this is easier to use later than bad indices)
% outlier_thres = the choosen number of standard devations used for MD cutoff
%
% UPDATES
% 05-15-09 SF: Renamed function from RemoveOutlines to MDOutlierTool, 
%              repeats calculation of MD for each STD cutoff tried, allows for STD-cutoff to be input (for automated), removes samples around noise using noise_spread
% 06-24-09 SF: Changed MD calculations to be iterated when trying different cutoffs. This will allow the removal of outliers that are 'hidding' behind the bigger outliers that were removed in the previous pass 
%              Note, this iterative MD calculation, though having the potental to remove 'hidden' outliers by creating a better model of the non-noise distribution,
%                it requires more human interaction (an art), harder to standardize, and is harder to expain in a paper.
%              Removed spread input
% 09-10-09 SF: Updated menus
% 05-19-10 SF: Updated menus, allows for no removal option

function [artifact_flg_vec] = MDOutlierTool(raw_data,outlier_thres)

% 06-24-09 SF: Added for keeping track of indices during iterations
original_idx_key=[1:size(raw_data,1)];
bad_sample_idx_from_orignal=[]; %06-24-09 SF: Added for keeping track of indices during iterations

%% Mahalanobis distance for each data point 

    mean_raw_data=mean(raw_data,1);
    inv_S=inv(cov(raw_data));% inverse of covarance

    prev_mah_dist=zeros(size(raw_data,1),1);

    for isample=1:size(raw_data,1)
        prev_mah_dist(isample)=sqrt((raw_data(isample,:)-mean_raw_data)*inv_S*(raw_data(isample,:)-mean_raw_data)');
    end

%% Remove outliers if given parameters

    % a cutoff was provided, no need to try cutoffs
    if ~isempty(outlier_thres)

        for iiteration=1:length(outlier_thres)
            
%% Removing Noisy samples            
            % Remove samples where MD is above threshold
            clean_idx=find(prev_mah_dist<mean(prev_mah_dist)+outlier_thres(iiteration)*std(prev_mah_dist)); % index of where outliers are

            % Turn into bad samples instead of clean (this is not necessary, but makes the next step easier)
            bad_sample_idx=1:size(prev_mah_dist,1);
            bad_sample_idx(:,clean_idx)=[]; % indicating bad samples
            
            % The indices of the bad samples relative to the original data file 06-24-09 SF
            % keep all samples that have ever been removed
            bad_sample_idx_from_orignal = [bad_sample_idx_from_orignal original_idx_key(bad_sample_idx)];
 
            % Turn ORIGINAL bad samples (with spread removed) to clean indices b/c it's easier to use % UPDATED 06-24-09 SF
            clean_idx=1:size(original_idx_key,2);
            clean_idx(:,bad_sample_idx_from_orignal)=[];
             
            disp(['    ' num2str(100-100*size(clean_idx,2)/size(original_idx_key,2)) '% of data removed with ' num2str(outlier_thres(iiteration)) ' STDs removed'])
            
            
%% Re calculate MD with new cutoff
            clear mean_raw_data inv_S 
            
            clean_raw_data=raw_data(clean_idx,:);
 
            mean_raw_data=mean(clean_raw_data,1);
            inv_S=inv(cov(clean_raw_data));% inverse of covarance

            clean_mah_dist=zeros(size(clean_raw_data,1),1);

            for isample=1:size(clean_raw_data,1)
                clean_mah_dist(isample)=sqrt((clean_raw_data(isample,:)-mean_raw_data)*inv_S*(clean_raw_data(isample,:)-mean_raw_data)');
            end
            
            prev_mah_dist=clean_mah_dist; % for iterative calculations of MD
            
        end % going thru all thresholds given

%% Remove outliers if NOT given parameters (manual)

    else     % no cutoff provided, so ask for one and try        
  
        figure;

        % Plot ALL rectified raw data
        subplot(4,1,1);
        plot(abs(Standardize(raw_data(1:10:end,:))))
        title('Original Rectified Data');xlabel('samples'); ylabel('Standardized')

        % Plot original MD
        subplot(4,1,2);
        plot(Standardize(prev_mah_dist(1:10:end,:)),'k')
        title('Original Mahalanobis Distance');xlabel('samples'); ylabel('Standardized MD');grid on
        
        % Plot new MD (SORTED)
        subplot(4,1,3);
        stem(sort((prev_mah_dist(1:10:end,:)),'descend'),'.-k')
        title('New Mahalanobis Distance');xlabel('sorted samples'); ylabel('Standardize MD');grid on
            
        % Plot Histogram of MD distribution
        subplot(4,1,4)
        hist(Standardize(prev_mah_dist),100);
        title('Original MD Distribution');xlabel('STD of MD'); ylabel('Sample Count');grid on
        
        % Sorting is okay, but histogram is better
        %         % Plot ALL rectified raw data (SORTED)
        %         subplot(2,2,2);
        %         plot(sort(abs(Standardize(raw_data(1:10:end,:))),'descend'))
        %         title('Original Rectified Data SORTED');xlabel('sorted samples'); ylabel('Standardized')
        %         axis([min(x_axis_values) max(x_axis_values) 0 max(max(abs(Standardize(raw_data(1:10:end,:)))))]);
        %
        %         % Plot original MD (SORTED)
        %         subplot(2,2,4);
        %         stem(sort(abs(Standardize(prev_mah_dist(1:10:end,:))),'descend'),'.-k')
        %         title('Original Mahalanobis Distance SORTED');xlabel('sorted samples'); ylabel('Standardize MD');grid on
        

%% Repeat trying cutoffs and spreads until satisfied
        satisfied_flag=0;
        clean_idx=1:size(raw_data,1);

        while (~satisfied_flag)

            % if there was no outlier_thres input or if a new one is desired, then allow for choice
            if isempty(outlier_thres)
                outlier_thres=input('Please input a threshold for outlier removal (X*STD). (Enter 0 to cancel):  ');
            end
            
            % Only proceed if the threshold is greater than zero
            if outlier_thres>0
                satisfied_flag=0;

          
%% Removing Noisy samples            
                % Remove samples where MD is above threshold
                clean_idx=[];
                clean_idx=find(prev_mah_dist<mean(prev_mah_dist)+outlier_thres*std(prev_mah_dist)); % index of where outliers are

                % Turn into bad samples instead of clean (this is not necessary, but makes the next step easier)
                bad_sample_idx=1:size(prev_mah_dist,1);
                bad_sample_idx(:,clean_idx)=[]; % indicating bad samples

                % make sure all indices are unique and not less than zero
    %             bad_sample_idx=unique( bad_sample_idx(bad_sample_idx>0,:) );



                % The indices of the bad samples relative to the original data file 06-24-09 SF
                % keep all samples that have ever been removed
                bad_sample_idx_from_orignal = [bad_sample_idx_from_orignal original_idx_key(bad_sample_idx)];

                % Turn ORIGINAL bad samples (with spread removed) to clean indices b/c it's easier to use % UPDATED 06-24-09 SF
                clean_idx=1:size(original_idx_key,2);
                clean_idx(:,bad_sample_idx_from_orignal)=[];

                disp(['    ' num2str(100-100*size(clean_idx,2)/size(original_idx_key,2)) '% of data removed with ' num2str(outlier_thres) ' STDs removed'])

%% Re calculate MD with new cutoff
                clear mean_raw_data inv_S 

                clean_raw_data=raw_data(clean_idx,:);

                mean_raw_data=mean(clean_raw_data,1);
                inv_S=inv(cov(clean_raw_data));% inverse of covarance

                clean_mah_dist=zeros(size(clean_raw_data,1),1);

                for isample=1:size(clean_raw_data,1)
                    clean_mah_dist(isample)=sqrt((clean_raw_data(isample,:)-mean_raw_data)*inv_S*(clean_raw_data(isample,:)-mean_raw_data)');
                end

%% Plot 

    % figure; hold all
    % plot(prev_mah_dist)
    % plot(prev_mah_dist(clean_idx,:),'k')

                figure;

    %             % Plot ALL rectified raw data
    %             subplot(4,1,1);
    %             plot(abs(Standardize(raw_data(1:10:end,:))))
    %             title('Original Rectified Data');xlabel('samples'); ylabel('Standardized')

                % Plot only 'clean' rectified raw data
                subplot(4,1,1);
                plot(abs(Standardize(raw_data(clean_idx(1:10:end),:))))
                title('Clean Rectified Data');xlabel('samples'); ylabel('Standardized')

                % Plot new MD
                subplot(4,1,2); hold all
                plot(Standardize(clean_mah_dist(1:10:end,:)),'k')            
                title('New Mahalanobis Distance');xlabel('samples'); ylabel('Standardize MD');grid on

                % Plot new MD (SORTED)
                subplot(4,1,3);
                stem(sort(Standardize(clean_mah_dist(1:10:end,:)),'descend'),'.-k')
                title('New Mahalanobis Distance');xlabel('sorted samples'); ylabel('Standardize MD');grid on

                % Plot Histogram of MD distribution
                subplot(4,1,4)
                hist(Standardize(clean_mah_dist),100);
                title('New MD Distribution');xlabel('STD of MD'); ylabel('Sample Count');grid on


                %             %*****Plot based on sorted samples*****
                %             
                %             % Plot only 'clean' rectified raw data (SORTED)
                %             subplot(2,2,2);
                %             plot(sort(abs(Standardize(raw_data(clean_idx(1:10:end),:))),'descend'))
                %             title(['Rectified Data with ' num2str(outlier_thres) ' STD removed']);xlabel('sorted samples'); ylabel('Standardized')
                %             axis([min(x_axis_values) max(x_axis_values) 0 max(max(abs(Standardize(raw_data(1:10:end,:)))))]);
                %             
                %             % Plot new MD (SORTED)
                %             subplot(2,2,4);
                %             stem(sort(abs(Standardize(clean_mah_dist(1:10:end,:))),'descend'),'.-k')
                %             title('New Mahalanobis Distance');xlabel('sorted samples'); ylabel('Standardize MD');grid on         

                outlier_thres=input('To continue, input a threshold for outlier removal (X*STD). Use most recent figure (Enter 0 to finish):  ');

                % if a new threshold was entered, repeat using this threshold
                if outlier_thres>0
                   satisfied_flag=0; 
                   prev_mah_dist=clean_mah_dist; % 06-24-09 SF: added for iterative calculations of MD
                else % if you want to quit, do so
                   satisfied_flag=1;
                end
            
            else % if you want to quit, do so
                satisfied_flag=1;
            end % Only proceed if the threshold is greater than zero
            
        end % trying cutoffs
            

    end % cutoff provided or not


    
    
    % Turn indices list into a vector of 1/0 flags indicating if point needs removing
    artifact_flg_vec=ones(size(raw_data,1),1);
    artifact_flg_vec(clean_idx,1)=0;
    
    
