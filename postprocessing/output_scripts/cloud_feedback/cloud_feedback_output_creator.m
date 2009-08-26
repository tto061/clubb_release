function[] = cloud_feedback_output_creator()
% GABLS3_OUTPUT_CREATOR This function creates netCDF files required by the GABLS 3 intercomparison. It uses CLUBB output files as source information.
%
%   This file is also meant to be an example for future MATLAB scripts to
%   convert CLUBB output for data submission in netCDF format.
%   Essentially a script for such a conversion will break down into these
%   sections:
%
%       File Input Section -
%           This is where the input files that are to be converted are
%           specified and read into MATLAB.
%
%       Definition Section -
%           This is where netCDF definitions will be written to the output
%           file. This includes information such as variable names,
%           variable attributes, and global attributes.
%
%       Conversion Section -
%           Since the input information produced by CLUBB may not match one
%           for one with the specifications of the output file, this
%           section is needed. Here all conversions of information will
%           occur such as converting temperature into potential
%           temperature.
%
%       Output File Section -
%           This section is respondsible for writing variable data to the
%           output file.
%


% Necessary include
addpath '../../matlab_include/'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   File Input Section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Source files of the GABLS3 case

% Path of the GrADS input files
scm_path = ['/home/senkbeir/clubb/output/'];

% zt Grid
smfile   = 'cloud_feedback_s6_zt.ctl';

% zm Grid
swfile   = 'cloud_feedback_s6_zm.ctl';

% sfc Grid
sfcfile  = 'cloud_feedback_s6_sfc.ctl';

% Reading the header from zt file
[filename,nz,z,ntimesteps,numvars,list_vars] = header_read([scm_path,smfile]);

% Used to navigate through time in all of the files. At the time this
% script was written, all of the GrADS output files generated by CLUBB used
% the same timestep.
t = 1:ntimesteps;
sizet = ntimesteps;

% Read in zt file's variables into MATLAB.
% Variables will be usable in the form <GrADS Variable Name>_array.
for i=1:numvars
    for timestep = 1:sizet
    	stringtoeval = [list_vars(i,:), ' = read_grads_clubb_endian([scm_path,filename],''ieee-le'',nz,t(timestep),t(timestep),i,numvars);'];
    	eval(stringtoeval);
    	str = list_vars(i,:);
        arraydata(1:nz,timestep) = eval([str,'(1:nz)']);
    	eval([strtrim(str),'_array = arraydata;']);
    end
    disp(i);
end

% Reading the header from zm file
[w_filename,w_nz,w_z,w_ntimesteps,w_numvars,w_list_vars] = header_read([scm_path,swfile]);
 
% Read in zm file's variables into MATLAB.
% Variables will be usable in the form <GrADS Variable Name>_array
for i=1:w_numvars
     for timestep = 1:sizet
         stringtoeval = [w_list_vars(i,:), ' = read_grads_clubb_endian([scm_path,w_filename],''ieee-le'',w_nz,t(timestep),t(timestep),i,w_numvars);'];
         eval(stringtoeval)
         str = w_list_vars(i,:);
         arraydata(1:w_nz,timestep) = eval([str,'(1:w_nz)']);
         eval([strtrim(str),'_array = arraydata;']);
     end
     disp(i);
end

% Reading the header from the sfc file
[sfc_filename,sfc_nz,sfc_z,sfc_ntimesteps,sfc_numvars,sfc_list_vars] = header_read([scm_path,sfcfile]);
 
% Read in sfc file's variables into MATLAB.
% Variables will be usable in the form <GrADS Variable Name>_array
for i=1:sfc_numvars
    for timestep = 1:sizet
        stringtoeval = [sfc_list_vars(i,:), ' = read_grads_clubb_endian([scm_path,sfc_filename],''ieee-le'',sfc_nz,t(timestep),t(timestep),i,sfc_numvars);'];
        eval(stringtoeval)
        str = sfc_list_vars(i,:);
        arraydata(1:sfc_nz,timestep) = eval([str,'(1:sfc_nz)']);
        eval([strtrim(str),'_array = arraydata(1:sfc_nz,:);']);
    end
    disp(i);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Conversion Section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Perform Necessary conversions
p_array = p_in_Pa_array * 0.01;
qtm_array = convert_units.total_water_mixing_ratio_to_specific_humidity( rtm_array );
T_forcing_array = convert_units.thlm_f_to_T_f( thlm_f_array, radht_array, exner_array );
ome_array = convert_units.w_wind_in_ms_to_Pas( wm_array, rho_array );
wt_array = convert_units.potential_temperature_to_temperature( wpthlp_array, exner_array );

wq_array = wprtp_array ./ (1 + rtm_array);

tdt_lw = radht_LW_array .* 86400 .* exner_array;
tdt_sw = radht_SW_array .* 86400 .* exner_array;
tdt_ls = (thlm_f_array - thlm_mc_array) .* 86400 .* exner_array;
qdt_ls = (rtm_f_array - rtm_mc_array) .* 86400 * 1000; % kg kg^{-1} s^{-1} * 86400 (s/day) * 1000 (g/kg)

time_out = 1:sizet;
for i=1:sizet
    time_out(i) =  i;
end

full_z  = convert_units.create_time_height_series( z, sizet );
full_w_z = convert_units.create_time_height_series( w_z, sizet );
full_sfc_z = convert_units.create_time_height_series( sfc_z, sizet );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Definition Section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create the new file. By default it is in definition mode.
ncid = netcdf.create('/home/senkbeir/nc_output/cloud_feedback_s6_scm_UWM_CLUBB_v2.nc','NC_WRITE');

% Define Global Attributes

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % General
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% % contact person
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'contact_person','Vince Larson (vlarson@uwm.edu) and Ryan Senkbeil (senkbeil@uwm.edu)');
 
% % Type of model where the SCM is derived from (climate model, mesoscale
% weather prediction model, regional model) ?
%netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'type_of_model_where_the_SCM_is_derived_from','Standalone SCM');

% Define dimensions

% Output Time
tdimid = netcdf.defdim(ncid,'time', sizet);

% Half Levels (zm)
levhdimid = netcdf.defdim(ncid,'levh', w_nz);

% Full Levels(zt)
levfdimid = netcdf.defdim(ncid,'levf', nz );

% Soil Levels(sfc)
levsdimid = netcdf.defdim(ncid,'levs', sfc_nz);

% Define variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hourly-averaged single-level fields as a function of time X(n_hours)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tvarid = define_variable( 'time' ,'hours since 2003-07-15 12:00:00', 'h', tdimid, ncid );
ccvarid = define_variable( 'cldtot', 'total cloud cover', '0 1', tdimid, ncid );
%cldlowvarid = define_variable( 'cldlow', 'low-level cloud amount', '0 1', tdimid, ncid );
tglwpvarid = define_variable( 'tglwp', 'vertically integrated liquid water', 'kg/m^2', tdimid, ncid );
precwvarid = define_variable( 'precw', 'precipitable water', 'kg/m^2', tdimid, ncid );
tsairvarid = define_variable( 'tsair', 'surface air temperature', 'K', tdimid, ncid );
psvarid = define_variable( 'ps', 'surface pressure', 'mb', tdimid, ncid );
%preccvarid = define_variable( 'precc', 'convective precipitation', 'mm/day', tdimid, ncid );
%preclvarid = define_variable( 'precl', 'stratiform precipitation', 'mm/day', tdimid, ncid );
prectvarid = define_variable( 'prect', 'total precipitation', 'mm/day', tdimid, ncid );
lhflxvarid = define_variable( 'lh', 'surface latent heat flux', 'W/m^2', tdimid, ncid );
shflxvarid = define_variable( 'sh', 'surface sensible heat flux', 'W/m^2', tdimid, ncid );
%pblhvarid = define_variable( 'pblh', 'PBL height', 'm', tdimid, ncid );
fsntcvarid = define_variable( 'fsntc', 'TOA SW net downward clear-sky radiation', 'W/m^2', tdimid, ncid );
fsntvarid = define_variable( 'fsnt', 'TOA SW net downward total-sky radiation', 'W/m^2', tdimid, ncid );
flntcvarid = define_variable( 'flntc', 'TOA LW clear-sky upward radiation', 'W/m^2', tdimid, ncid );
flntvarid = define_variable( 'flnt', 'TOA LW total-sky upward radiation', 'W/m^2', tdimid, ncid );
fsnscvarid = define_variable( 'fsnsc', 'Surface SW net downward clear-sky radiation', 'W/m^2', tdimid, ncid );
fsnsvarid = define_variable( 'fsns', 'Surface SW net downward total-sky radiation', 'W/m^2', tdimid, ncid );
flnscvarid = define_variable( 'flnsc', 'Surface LW net upward clear-sky radiation', 'W/m^2', tdimid, ncid );
flnsvarid = define_variable( 'flns', 'Surface LW net upward total-sky radiation', 'W/m^2', tdimid, ncid );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hourly-averaged vertical profiles of multi-level fields as a function of time, X(n_levels, n_hours)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pvarid = define_variable( 'p' ,'pressure', 'mb', [levfdimid tdimid], ncid );
tinkvarid = define_variable( 'T' ,'temperature', 'K', [levfdimid tdimid], ncid );
qvvarid = define_variable( 'qv' ,'water vapour mixing ratio', 'g/kg', [levfdimid tdimid], ncid );
qlvarid = define_variable( 'ql' ,'liquid water mixing ratio', 'g/kg', [levfdimid tdimid], ncid );
cfvarid = define_variable( 'cloud' ,'cloud fraction', '0 1', [levfdimid tdimid], ncid );
%muvarid = define_variable( 'mu' ,'updraft convective mass flux', 'kg m^-2 s^-1', [levfdimid tdimid], ncid );
%mdvarid = define_variable( 'md' ,'downdraft convective mass flux', 'kg m^-2 s^-1', [levfdimid tdimid], ncid );
%tdtturbvarid = define_variable( 'tdt_turb' ,'dT/dt due to PBL-scheme', 'K/day', [levfdimid tdimid], ncid );
%tdtcondvarid = define_variable( 'dt_cond' ,'dT/dt due to large-scale condensation scheme', 'K/day', [levfdimid tdimid], ncid );
%tdtshalvarid = define_variable( 'tdt_shal' ,'dT/dt due to shallow (or total if not separated) convection scheme', 'K/day', [levfdimid tdimid], ncid );
%tdtdeepvarid = define_variable( 'tdt_deep' ,'dT/dt due to deep (or total if not separated) convection scheme', 'K/day', [levfdimid tdimid], ncid );
tdtlwvarid = define_variable( 'tdt_lw' ,'dT/dt due to LW radiation', 'K/day', [levfdimid tdimid], ncid );
tdtswvarid = define_variable( 'tdt_sw' ,'dT/dt due to SW radiation', 'K/day', [levfdimid tdimid], ncid );
tdtlsvarid = define_variable( 'tdt_ls' ,'dT/dt due to large-scale forcing', 'K/day', [levfdimid tdimid], ncid );
%qdtturbvarid = define_variable( 'qdt_turb' ,'dqv/dt due to PBL-scheme', '(g/kg)/day', [levfdimid tdimid], ncid );
%qdtcondvarid = define_variable( 'qdt_cond' ,'dqv/dt due to large-scale condensation scheme', '(g/kg)/day', [levfdimid tdimid], ncid );
%qdtshalvarid = define_variable( 'qdt_shal' ,'dqv/dt due to shallow convection scheme', '(g/kg)/day', [levfdimid tdimid], ncid );
%qdtdeepvarid = define_variable( 'qdt_deep' ,'dqv/dt due to deep convection scheme', '(g/kg)/day', [levfdimid tdimid], ncid );
qdtlsvarid = define_variable( 'qdt_ls' ,'dqv/dt due to large-scale forcing', '(g/kg)/day', [levfdimid tdimid], ncid );
%wdtturbvarid = define_variable( 'wdt_turb' , 'dql/dt due to PBL-scheme', '(g/kg)/day', [levfdimid tdimid], ncid );
%wdtcondvarid = define_variable( 'wdt_cond' , 'dql/dt due to large-scale condensation scheme (c minus e)', '(g/kg)/day', [levfdimid tdimid], ncid );
%wdtshalvarid = define_variable( 'wdt_shal' , ' dql/dt due to shallow convection scheme', '(g/kg)/day', [levfdimid tdimid], ncid );
%wdtdeepvarid = define_variable( 'wdt_deep' , 'dql/dt due to deep convection scheme', '(g/kg)/day', [levfdimid tdimid], ncid );
%wdtprecvarid = define_variable( 'wdt_prec' , 'dql/dt due to conversion to precipitation', '(g/kg)/day', [levfdimid tdimid], ncid );
%wdtsedivarid = define_variable( 'wdt_sedi' , 'dql/dt due to cloud sedimentation', '(g/kg)/day', [levfdimid tdimid], ncid );

netcdf.setFill(ncid,'NC_FILL');

% End definition
netcdf.endDef(ncid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Output File Section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hourly-averaged single-level fields output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
netcdf.putVar( ncid, tvarid, time_out);
netcdf.putVar( ncid, ccvarid, cc_array(1,:));
netcdf.putVar( ncid, tglwpvarid, lwp_array);
netcdf.putVar( ncid, precwvarid, vwp_array);
netcdf.putVar( ncid, tsairvarid, T_in_K_array(1,:));
netcdf.putVar( ncid, psvarid, p_array(1,:));
netcdf.putVar( ncid, prectvarid, rain_rate_array);
netcdf.putVar( ncid, lhflxvarid, lh_array);
netcdf.putVar( ncid, shflxvarid, sh_array);
netcdf.putVar( ncid, fsntvarid, Frad_SW_down_array(w_nz,:) - Frad_SW_up_array(w_nz,:));
netcdf.putVar( ncid, flntvarid, Frad_LW_up_array(w_nz,:)  - Frad_LW_down_array(w_nz,:));
netcdf.putVar( ncid, fsnsvarid, Frad_SW_down_array(1,:) - Frad_SW_up_array(1,:));
netcdf.putVar( ncid, flnsvarid, Frad_LW_up_array(1,:) - Frad_LW_down_array(1,:));

netcdf.putVar( ncid, flnscvarid, fulwcl_array(end,:) - fdlwcl_array(end,:));
%netcdf.putVar( ncid, preccvarid, );
%netcdf.putVar( ncid, preclvarid, );
netcdf.putVar( ncid, fsnscvarid, fdswcl_array(end,:));
%netcdf.putVar( ncid, pblhvarid, );
netcdf.putVar( ncid, fsntcvarid, fdswcl_array(1,:) - fuswcl_array(1,:));
netcdf.putVar( ncid, flntcvarid, fulwcl_array(1,:) - fdlwcl_array(1,:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hourly-averaged vertical profiles of multi-level fields output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
netcdf.putVar( ncid, pvarid, p_array);
netcdf.putVar( ncid, tinkvarid, T_in_K_array);
netcdf.putVar( ncid, qvvarid, (rtm_array - rcm_array) .* 1000);
netcdf.putVar( ncid, qlvarid, rcm_array .* 1000);
netcdf.putVar( ncid, cfvarid, cloud_frac_array);
netcdf.putVar( ncid, tdtlwvarid, tdt_lw);
netcdf.putVar( ncid, tdtswvarid, tdt_sw);
netcdf.putVar( ncid, tdtlsvarid, tdt_ls);
netcdf.putVar( ncid, qdtlsvarid, qdt_ls);

%netcdf.putVar( ncid, muvarid, );
%netcdf.putVar( ncid, mdvarid, );
%netcdf.putVar( ncid, tdtturbvarid, );
%netcdf.putVar( ncid, tdtcondvarid, );
%netcdf.putVar( ncid, tdtshalvarid, );
%netcdf.putVar( ncid, tdtdeepvarid, );
%netcdf.putVar( ncid, qdtturbvarid, );
%netcdf.putVar( ncid, qdtcondvarid, );
%netcdf.putVar( ncid, qdtshalvarid, );
%netcdf.putVar( ncid, qdtdeepvarid, );
%netcdf.putVar( ncid, wdtturbvarid, );
%netcdf.putVar( ncid, wdtcondvarid, );
%netcdf.putVar( ncid, wdtshalvarid, );
%netcdf.putVar( ncid, wdtdeepvarid, );
%netcdf.putVar( ncid, wdtprecvarid, );
%netcdf.putVar( ncid, wdtsedivarid, );

% Close file
netcdf.close(ncid);
end

function varid = define_variable( shrt_name, long_name, units, dim_ids, file_id )

varid = netcdf.defVar(file_id, shrt_name, 'NC_FLOAT',dim_ids);
netcdf.putAtt(file_id, varid,'unit',units);
netcdf.putAtt(file_id, varid,'long_name',long_name);

end
