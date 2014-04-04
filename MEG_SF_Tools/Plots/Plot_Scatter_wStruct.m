function Plot_Scatter_wStruct(data_struct,indep_field,dep_field_list,catagorical_field,varargin) % fit_line, color_list, annotate_flag, indep_label, dep_label
% Scatter plot of each entry in data_struct(#). Just put a bunch of stuff in a struct and bingo, you're done
%
% indep_field: field name for that will be plotted as the x-axis values (data_struct.'indep_field')
% dep_field_list: field name for that will be plotted as the y-axis values (data_struct.'dep_field(#)')
%      Each entry in dep_field is a subplot
% catagorical_field [OPTIONAL]: Each scatter-point is made into a diffeerent color based on the
%      catagorical data found in data_struct.'catagorical_field'.
%      Currently had preset colors, does jet past 4 catagorical values
% OPTIONS:
%     fit_line: 'cat' = draws linear fit lines for each catagory [DEFAULT],
%               'all' = draw line for each catagory AND all whole group,
%               'group' = draw line only for the whole group
%               'none' = no lines
%     annotate_flag: 1 = put slope and R values for fit on figure [DEFAULT], 0 = don't
%     color_list: RGB or color-letter list, DEFAULT = ['krgb']';
%     indep_label: alternative name for the x-axis (DEFAULT = field name)
%     dep_label: alternative names for the y-axis (cell array) (DEFAULT = field name list)
%     marker_field: Each marker can get a label, like subject id
%
% field names can have subfields (e.g. dep_field='Screening.Finger' ==> data_struct.Screening.Finger
% NOTE: dependent and independent variables must be numerical or will be considered NaN
%
% IMPROVMENTS:
%   make work for nonnumaric x and y
%   mulitiple dep vars?
%
% SEE: scatterhist.m
%
% 2013-09-25 Foldes
% UPDATES:
% 2013-09-30 Foldes: switched words dep and indep (dumb dumb)
% 2013-10-11 Foldes: Metadata-->DB

%% VARARGIN PARSE

% Needs to be a cell
if ~iscell(dep_field_list)
    org_dep_list = dep_field_list;
    clear dep_field_list
    dep_field_list{1}=org_dep_list;
end


defaults.fit_line='cat'; % default is catagorical only
defaults.annotate_flag=1;
defaults.color_list = ['krgb']'; % Default colors; you shouldn't have too many, or use jet (see below)
defaults.indep_label=indep_field;
defaults.dep_label=dep_field_list;
defaults.fig = [];
defaults.marker_field = [];
parms = varargin_extraction(defaults,varargin);

if ~iscell(parms.dep_label)
    org_dep_label = parms.dep_label;
    parms.dep_label = [];
    parms.dep_label{1}=org_dep_label;
end

%% Make Color List for Catagorical data

if exist('catagorical_field') && ~isempty(catagorical_field)
    % catagories that could be possible
    catagorical_list = DB_lookup_unique_entries(data_struct,catagorical_field);
    
    % man you want a a lot of colors, use jet
    if size(catagorical_list,2)>length(parms.color_list)
        jet_colors = colormap('jet');
        parms.color_list = jet_colors(1:size(jet_colors,1)/length(catagorical_list):end,:);
    end
else % no catagories
    catagorical_list = 1;
end

%% Ploting loop

if isempty(parms.fig)
    parms.fig = figure;
end
figure(parms.fig);hold all

num_dep_vars = length(dep_field_list);
for ivar = 1:num_dep_vars
    
    current_dep_field=dep_field_list{ivar};
    
    % Don't do a subplot if there is only one entry (this is needed for controlling subplots outside function)
    if num_dep_vars>1
        subplot(num_dep_vars,1,ivar);hold all
    end
    
    % a counter for storing data by catagory
    cnt_bycat=zeros(1,size(catagorical_list,2)); % if no catagories, just a single counter
    
    clear temp_value x y points_bycat
    for ientry = 1:length(data_struct)
        
        % Get Y values
        eval(['temp_value = data_struct(ientry).' current_dep_field ';'])
        if isnumeric(temp_value) % errors will be passed as strings
            y = temp_value;
        else
            y = NaN;
        end
        
        % Get X values
        eval(['temp_value = data_struct(ientry).' indep_field ';'])
        if isnumeric(temp_value)
            x = temp_value;
        else
            x = NaN;
        end
        
        if exist('catagorical_field') && ~isempty(catagorical_field)
            % Get color from catagorical data
            eval(['current_catagorical_value = data_struct(ientry).' catagorical_field ';'])
            current_cat = find_lists_overlap_idx(catagorical_list,current_catagorical_value);
        else
            current_cat = 1;
        end
        current_color = parms.color_list(current_cat,:);
        
        % store data by catagory
        cnt_bycat(current_cat)=cnt_bycat(current_cat)+1;
        points_bycat.x{current_cat}(cnt_bycat(current_cat))=x;
        points_bycat.y{current_cat}(cnt_bycat(current_cat))=y;
        
        % Plot
        %plot(x,y,'o','Color',current_color,'MarkerSize',10);%20+(5*(current_cat-1)) );
        plot(x,y,'.','Color',current_color,'MarkerSize',30);%20+(5*(current_cat-1)) );
        % Plot_TransparentMarker(x,y,1,current_color,0.05,parms.fig); % doesn't work yet
        
        
        if ~isempty(parms.marker_field) && parms.annotate_flag == 1
            eval(['current_marker_name = data_struct(ientry).' parms.marker_field ';'])
            text(x,y,current_marker_name,...
                'HorizontalAlignment','right',...
                'VerticalAlignment','middle',...
                'FontSize',8,'Color',current_color);
        end
        
    end % struct entires
    
    num_cat = size(points_bycat.x,2);
   
    %% Make lines
    
    if ~strcmpi(parms.fit_line,'none')
        if strcmpi(parms.fit_line,'cat') || strcmpi(parms.fit_line,'all')
            for current_cat =1:num_cat
                clear r m b x y
                [r,m,b]=regression(points_bycat.x{current_cat},points_bycat.y{current_cat});
                x=[min(points_bycat.x{current_cat}):.1:max(points_bycat.x{current_cat})];
                y=m*x+b;
                current_color = parms.color_list(current_cat,:);
                % plot
                plot(x,y,'--','Color',current_color,'LineWidth',2)
                % annotate
                line_stats(current_cat).m=m;
                line_stats(current_cat).r=r;
                if parms.annotate_flag == 1
                    middle_idx = round(length(x)/2);
                    %text2write = {['m = ' num2str(round_sig(m,-2))] , ['(R = ' num2str(round_sig(r,-2)) ')'],' \downarrow '};
                    text2write = {['(R = ' num2str(round_sig(r,-2)) ')'],' \downarrow '};
                    text(x(middle_idx),y(middle_idx),text2write,...
                        'HorizontalAlignment','center',...
                        'VerticalAlignment','Bottom',...
                        'FontSize',10,'Color',current_color);
                    % 'Rotation',rad2deg(atan(m))); % THIS ROTATION DOESN'T HAVE THE RIGHT ANGLE FOR SOME REASON
                end
            end
        end % line type
        
        % Plot overall line also (iff requestsed)
        if ( strcmpi(parms.fit_line,'all') || strcmpi(parms.fit_line,'group') ) && (num_cat > 1)
            % combine all points
            all_points.x = [];all_points.y = [];
            for current_cat =1:num_cat
                all_points.x = [all_points.x points_bycat.x{current_cat}];
                all_points.y = [all_points.y points_bycat.y{current_cat}];
            end
            clear r m b x y
            [r,m,b]=regression(all_points.x,all_points.y);
            x=[min(all_points.x):.1:max(all_points.x)];
            y=m*x+b;
            % plot
            current_color = [1 1 1]*0.4;
            plot(x,y,'--','Color',current_color,'LineWidth',2)
            % annotate
            line_stats(num_cat+1).m=m;
            line_stats(num_cat+1).r=r;
            if parms.annotate_flag == 1
                middle_idx = round(length(x)/2);
                text2write = {['m = ' num2str(round_sig(m,-2))] , ['(R = ' num2str(round_sig(r,-2)) ')'],' \downarrow '};
                text(x(middle_idx),y(middle_idx),text2write,...
                    'HorizontalAlignment','center',...
                    'VerticalAlignment','Bottom',...
                    'FontSize',10,'Color',current_color);
                % 'Rotation',rad2deg(atan(m))); % THIS ROTATION DOESN'T HAVE THE RIGHT ANGLE FOR SOME REASON
            end
        end % line type
        
    end % lines at all
    
    ylabel(str4plot(parms.dep_label{ivar}))
    axis 'square'
end % plotting loop
xlabel(str4plot(parms.indep_label))


%% Annotate w/ catagorical info
if parms.annotate_flag == 1
    text_input = [str4plot(catagorical_field) catagorical_list];
    Figure_Annotate(text_input,'Color',['k' parms.color_list'],'Location','NorthWest')
end
