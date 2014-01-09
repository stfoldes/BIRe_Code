% target_code = RemoveStrays(target_code)
% Stephen Foldes 09/13/11
%
% Makes small jumps in target_code equal to the next stable value. 
% The number of samples required to be considered small (small_change_thres) can be input or defaulted to 5.
% Does not remove any samples
% Particularly useful for target code recorded in MEG-fif files via parallel port

function target_code = RemoveStrays(target_code,small_change_thres)

    if ~exist('small_change_thres')
        small_change_thres = 5;
    end

    change_idx = [1; find(abs(diff(target_code))>0); length(target_code)];
    samples_between_changes = diff(change_idx);
    small_change_num = find(samples_between_changes<=small_change_thres);

    %     figure;hold all
    %     plot(target_code,'k')

    % Go through each small change and make the value the same as the next
    for ichange = 1:size(small_change_num,1)
        
        % Look for when the next stable value is
        next_stable_change = 1;
        while max(change_idx(small_change_num(ichange)) + (next_stable_change+1) == (change_idx(small_change_num)+1))~=0 % always +1 b/c of diff()
            next_stable_change = next_stable_change + 1;
        end
        
        % Force small change points to be following values (but only if the following values are stable)
        target_code(change_idx(small_change_num(ichange))+1)=target_code(change_idx(small_change_num(ichange))+(next_stable_change+1));
        
    end

    %     plot(target_code,'r','LineWidth',2)

