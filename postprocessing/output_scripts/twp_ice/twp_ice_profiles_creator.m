function[] = twp_ice_profiles_creator(ensembleNumber)
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

case_name = 'twp_ice';

% Path of the GrADS input files
scm_path = ['/home/nielsenb/clubb/output/'];
output_path = ['/home/nielsenb/clubb/postprocessing/output_scripts/twp_ice/profiles.CLUBB_p', sprintf('%02d',ensembleNumber), '.nc'];

% zt Grid
smfile   = [case_name, '_zt.ctl'];

% zm Grid
swfile   = [case_name, '_zm.ctl'];

% sfc Grid
sfcfile  = [case_name, '_sfc.ctl'];

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
qtm_array = convert_units.total_water_mixing_ratio_to_specific_humidity( rtm_array );
T_forcing_array = convert_units.thlm_f_to_T_f( thlm_f_array, radht_array, exner_array );
ome_array = convert_units.w_wind_in_ms_to_Pas( wm_array, rho_array );
wt_array = convert_units.potential_temperature_to_temperature( wpthlp_array, exner_array );
rvm_array = rtm_array - rcm_array;
rh_array = rtm_array ./ rsat_array;
q1_array = (thlm_bt_array - (thlm_f_array - thlm_mc_array)) .* exner_array;
q2_array = rtm_bt_array - (rtm_f_array - rtm_mc_array);
tqsw_array = radht_SW_array .* 86400 .* exner_array;
tqlw_array = radht_LW_array .* 86400 .* exner_array;

wq_array = wprtp_array ./ (1 + rtm_array);


time_out = 1:sizet;
for i=1:sizet
    time_out(i) =  i*10.0*60.0;
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
ncid = netcdf.create(output_path,'NC_WRITE');

% Define Global Attributes

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % General
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% % Reference to the model
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Reference_to_the_model','Golaz et. al 2002');

% % contact person
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'contact_person','Joshua Fasching (faschinj@uwm.edu)');
 
% % Type of model where the SCM is derived from (climate model, mesoscale
% weather prediction model, regional model) ?
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'type_of_model_where_the_SCM_is_derived_from','Standalone SCM');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Surface Scheme
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% % Is it a force-restore type or a multi-layer type?
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'), ... 
    'Is_it_a_force-restore_type_or_a_multi-layer_type','force-restore');

% %Does it have skin layer?
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'), ...
    'Does_it_have_skin_layer','No');

% %Is there a tile approach?
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'), ...
    'Is_there_a_tile_approach','No');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Turbulence Scheme
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %Turbulence scheme  (e.g., K profile, TKE-l, ...)
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'), ... 
    'Turbulence_scheme',...
    'Higher order closure');

% %Formulation of eddy diffusivity K.
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'), ...
    'Formulation_of_eddy_diffusivity_K.', ...
    'No eddy diffusivitiy; fluxes are prognosed');

% % For E-l and Louis-type scheme: give formulation length scale.
% % For K-profile: how is this  profile determined ? (e.g., based on
% Richardson, Brunt-Vaisala frequency (N^2),  Parcel method, other.
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), ...
    'How_is_this_profile_determined','Parcel method');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Other
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Any other model specific aspects you find relevent for this intercomparison.

% % Any deviation from the prescribed set up that you had to make because
% of the specific structure of your model
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), ... 
    ['Any_deviation_from_the_prescribed_set_up_that_you_had_to', ...
    'make_because_of_the_specific_structure_of_your_model'], ...
    ['We needed to set the temperature of the top soil layer and', ...
    ' vegetation to match the surface air at the initial time.']);

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
% Full/Half Level Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

timevarid = define_variable( 'time' ,'seconds since 2006-07-01 12:00:00', 's', tdimid, ncid );
hvarid = define_variable( 'h' ,'height', 'm', [levfdimid tdimid], ncid );
pvarid = define_variable( 'p' ,'pressure', 'Pa', [levfdimid tdimid], ncid );
tvarid = define_variable( 'T' ,'temperature', 'K', [levfdimid tdimid], ncid );
thvarid = define_variable( 'theta' ,'potential temperature', 'K', [levfdimid tdimid], ncid );
rhovarid = define_variable( 'rho' ,'density', 'kg m^-3', [levfdimid tdimid], ncid );
wvarid = define_variable( 'w' ,'vertical velocity', 'm s^-1', [levfdimid tdimid], ncid );
qvvarid = define_variable( 'qv' ,'water vapor mixing ratio', 'kg kg^-1', [levfdimid tdimid], ncid );
rhvarid = define_variable( 'RH' ,'q/q^∗ where q^∗ is the saturation mixing ratio over water', '0 1', [levfdimid tdimid], ncid );
qcvarid = define_variable( 'qc' ,'cloud water mixing ratio', 'kg kg^-1', [levfdimid tdimid], ncid );
qivarid = define_variable( 'qi' ,'cloud ice mixing ratio', 'kg kg^-1', [levfdimid tdimid], ncid );
qrvarid = define_variable( 'qr' ,'rain mixing ratio', 'kg kg^-1', [levfdimid tdimid], ncid );
cfvarid = define_variable( 'CF' ,'cloud fraction', '0 1', [levfdimid tdimid], ncid );
q1varid = define_variable( 'Q1' ,'apparent heat source', 'K day^-1', [levfdimid tdimid], ncid );
q2varid = define_variable( 'Q2' ,'apparent moisture source', 'K day^-1', [levfdimid tdimid], ncid );
tqswvarid = define_variable( 'TQsw' ,'total sky shortwave radiative heating rate', 'K day^-1', [levfdimid tdimid], ncid );
tqlwvarid = define_variable( 'TQlw' ,'total sky longwave radiative heating rate', 'K day^-1', [levfdimid tdimid], ncid );


netcdf.setFill(ncid,'NC_FILL');

% End definition
netcdf.endDef(ncid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Output File Section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mean State Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

netcdf.putVar( ncid, timevarid, time_out);
netcdf.putVar(ncid,hvarid,full_z);
netcdf.putVar(ncid,pvarid,p_in_Pa_array);
netcdf.putVar(ncid,tvarid,T_in_K_array);
netcdf.putVar(ncid,thvarid,thlm_array);
netcdf.putVar(ncid,rhovarid,rho_array);
netcdf.putVar(ncid,wvarid,wm_array);
netcdf.putVar(ncid,qvvarid,rvm_array);
netcdf.putVar(ncid,rhvarid,rh_array);
netcdf.putVar(ncid,qcvarid,rcm_array);
netcdf.putVar(ncid,qivarid,ricem_array);
netcdf.putVar(ncid,qrvarid,rrainm_array);
netcdf.putVar(ncid,cfvarid,cf_array);
netcdf.putVar(ncid,q1varid,q1_array);
netcdf.putVar(ncid,q2varid,q2_array);
netcdf.putVar(ncid,tqswvarid,tqsw_array);
netcdf.putVar(ncid,tqlwvarid,tqlw_array);

% Close file
netcdf.close(ncid);
end

function varid = define_variable( shrt_name, long_name, units, dim_ids, file_id )

varid = netcdf.defVar(file_id, shrt_name, 'NC_FLOAT',dim_ids);
netcdf.putAtt(file_id, varid,'unit',units);
netcdf.putAtt(file_id, varid,'long_name',long_name);

end









