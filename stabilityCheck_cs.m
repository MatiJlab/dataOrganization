function stabilityCheck_cs (data_cs_dir,data_ss_dir,data_cs_speed, data_ss_speed, raster_params);


smoothing_margins = 100; % ms
raster_params.smoothing_margins = smoothing_margins;
SD = 10; %smoothing parameter
num_dir = 2; % number of relevent directions

% get PD and Null from speed task
if ~(min([data_cs_speed.trials.screen_rotation])== max([data_cs_speed.trials.screen_rotation]))
    disp(['Speed tuning task : Screen was rotated within session in cell ' num2str(data_cs_speed.info.cell_ID)])
end   
if ~(min([data_cs_dir.trials.screen_rotation])== max([data_cs_dir.trials.screen_rotation]))
    disp(['Direction tuning task : Screen was rotated within session in cell ' num2str(data_cs_speed.info.cell_ID)])
end

speed_rot = data_cs_speed.trials(1).screen_rotation;
dir_rot = data_cs_dir.trials(1).screen_rotation;
[pd_speed,h_speed] = getPD(data_ss_speed, raster_params);
pd_speed_val = str2num(pd_speed);
pd_speed2dir = num2str (mod(pd_speed_val - speed_rot + dir_rot,360));
null_speed2dir = num2str (mod(pd_speed_val - speed_rot + dir_rot + 180,360));
directions_dir = {null_speed2dir,pd_speed2dir};

ts = -raster_params.time_before:raster_params.time_after;

if h_speed 
    figure;

    %% speed task

    % get reward conditions
    RS_in_name = regexp({data_cs_speed.trials.name},'RS');
    RL_in_name = regexp({data_cs_speed.trials.name},'RL');
    RS_bool = ~cellfun(@isempty,RS_in_name);
    RL_bool = ~cellfun(@isempty,RL_in_name);

    % get direcions
    expression = '(?<=d)[0-9]*'; 
    [match_d,~] = regexp({data_cs_speed.trials.name},expression,'match','split','forceCellOutput');
    match_d = [match_d{:}];
    directions = uniqueRowsCA(match_d');
    directions = natsortfiles(directions');

    % get vellocities
    expression = '(?<=v)[0-9]*'; 
    [match_v,~] = regexp({data_cs_speed.trials.name},expression,'match','split','forceCellOutput');
    match_v = [match_v{:}];
    vellocities = uniqueRowsCA(match_v');
    vellocities = natsortfiles(vellocities');

    % indices of failed trials
    fail_bool = [data_cs_speed.trials.fail];
    vel_bool = strcmp(match_v,'20');


    dir_bool = strcmp(match_d,pd_speed);
    if raster_params.iclude_failed
            ind_RL = find(vel_bool.*dir_bool.*RL_bool);
            ind_RS = find(vel_bool.*dir_bool.*RS_bool);
    else
            ind_RL = find(vel_bool.*dir_bool.*RL_bool.*(~fail_bool));
            ind_RS = find(vel_bool.*dir_bool.*RS_bool.*(~fail_bool));
    end
    % create rasters
     raster_RS = getRaster( data_cs_speed, ind_RS, raster_params );
     raster_RL = getRaster( data_cs_speed, ind_RL, raster_params );

    % psths and remove margins

    psth_RS_raw =  raster2psth (raster_RS,SD); 
    psth_RL_raw =  raster2psth (raster_RL,SD); 
    psth_RS  = psth_RS_raw((smoothing_margins+1):(length(psth_RS_raw)-smoothing_margins));
    psth_RL = psth_RL_raw((smoothing_margins+1):(length(psth_RL_raw)-smoothing_margins));
    raster_RS = raster_RS((smoothing_margins+1):(length(raster_RS)-smoothing_margins),:);
    raster_RL = raster_RL((smoothing_margins+1):(length(raster_RL)-smoothing_margins),:);

    subplot (3,2,1)
    pcolor(ts, 1:size(raster_RS',1), -raster_RS'); shading flat; colormap(hot)
    title ('RS - Speed Task')
    xlabel ('time to movement onset')

    subplot (3,2,3)
    pcolor(ts, 1:size(raster_RL',1), -raster_RL'); shading flat; colormap(hot)
    title ('RL - Speed Task')
    xlabel ('time to movement onset')

    subplot (3,2,5)
    plot(ts, psth_RS, 'r'); hold on
    plot(ts, psth_RL, 'b'); hold on
    legend('RS','RL')
    title ('Speed Task')
    xlabel ('time to movement onset')

    %% direction task

    % indices of failed trials
    fail_bool = [data_cs_speed.trials.fail];
    vel_bool = strcmp(match_v,'20');

    % get reward conditions
    RS_in_name = regexp({data_cs_dir.trials.name},'RS');
    RL_in_name = regexp({data_cs_dir.trials.name},'RL');
    RS_bool = ~cellfun(@isempty,RS_in_name);
    RL_bool = ~cellfun(@isempty,RL_in_name);

    % get direcions
    expression = '(?<=d)[0-9]*'; 
    [match_d,~] = regexp({data_cs_dir.trials.name},expression,'match','split','forceCellOutput');
    match_d = [match_d{:}];
    directions = uniqueRowsCA(match_d');
    directions = natsortfiles(directions');

    % get vellocities
    expression = '(?<=v)[0-9]*'; 
    [match_v,~] = regexp({data_cs_dir.trials.name},expression,'match','split','forceCellOutput');
    match_v = [match_v{:}];
    vellocities = uniqueRowsCA(match_v');
    vellocities = natsortfiles(vellocities');

    % indices of failed trials
    fail_bool = [data_cs_dir.trials.fail];
    vel_bool = strcmp(match_v,'20');

    dir_bool = strcmp(match_d,pd_speed2dir);
    if raster_params.iclude_failed
            ind_RL = find(vel_bool.*dir_bool.*RL_bool);
            ind_RS = find(vel_bool.*dir_bool.*RS_bool);
    else
            ind_RL = find(vel_bool.*dir_bool.*RL_bool.*(~fail_bool));
            ind_RS = find(vel_bool.*dir_bool.*RS_bool.*(~fail_bool));
    end
    % create rasters
    raster_RS = getRaster( data_cs_dir, ind_RS, raster_params );
    raster_RL = getRaster( data_cs_dir, ind_RL, raster_params );

    % psths and remove margins

    psth_RS_raw =  raster2psth (raster_RS,SD); 
    psth_RL_raw =  raster2psth (raster_RL,SD); 
    psth_RS  = psth_RS_raw((smoothing_margins+1):(length(psth_RS_raw)-smoothing_margins));
    psth_RL = psth_RL_raw((smoothing_margins+1):(length(psth_RL_raw)-smoothing_margins));
    raster_RS = raster_RS((smoothing_margins+1):(length(raster_RS)-smoothing_margins),:);
    raster_RL = raster_RL((smoothing_margins+1):(length(raster_RL)-smoothing_margins),:);

    subplot (3,2,2)
    pcolor(ts, 1:size(raster_RS',1), -raster_RS'); shading flat; colormap(hot)
    title ('RS - Direction Task')
    xlabel ('time to movement onset')

    subplot (3,2,4)
    pcolor(ts, 1:size(raster_RL',1), -raster_RL'); shading flat; colormap(hot)
    title ('RL - Direction Task')
    xlabel ('time to movement onset')

    subplot (3,2,6)
    plot(ts, psth_RS, 'r'); hold on
    plot(ts, psth_RL, 'b'); hold on
    legend('RS','RL')
    title ('Direction Task')
    xlabel ('time to movement onset')
end



           





