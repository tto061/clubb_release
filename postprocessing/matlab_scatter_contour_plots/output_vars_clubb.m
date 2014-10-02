% $Id$
function [ varname_clubb, units_corrector_type, ...
           num_var_clubb, num_tot_var_clubb ] = output_vars_clubb

idx_count = 0;

%============= Add Model Field Variables Here =============================

% w_1 (m/s).
idx_count = idx_count + 1;
global idx_w_1
idx_w_1 = idx_count;
units_corrector_type(idx_w_1) = 0;
varname_clubb(idx_w_1,1:3) = 'w_1';

% w_2 (m/s).
idx_count = idx_count + 1;
global idx_w_2
idx_w_2 = idx_count;
units_corrector_type(idx_w_2) = 0;
varname_clubb(idx_w_2,1:3) = 'w_2';

% mu_rr_1_n (ln(kg/kg)).
idx_count = idx_count + 1;
global idx_mu_rr_1_n
idx_mu_rr_1_n = idx_count;
units_corrector_type(idx_mu_rr_1_n) = 0;
varname_clubb(idx_mu_rr_1_n,1:9) = 'mu_rr_1_n';

% mu_rr_2_n (ln(kg/kg)).
idx_count = idx_count + 1;
global idx_mu_rr_2_n
idx_mu_rr_2_n = idx_count;
units_corrector_type(idx_mu_rr_2_n) = 0;
varname_clubb(idx_mu_rr_2_n,1:9) = 'mu_rr_2_n';

% varnce_w_1 (m^2/s^2).
idx_count = idx_count + 1;
global idx_varnce_w_1
idx_varnce_w_1 = idx_count;
units_corrector_type(idx_varnce_w_1) = 0;
varname_clubb(idx_varnce_w_1,1:10) = 'varnce_w_1';

% varnce_w_2 (m^2/s^2).
idx_count = idx_count + 1;
global idx_varnce_w_2
idx_varnce_w_2 = idx_count;
units_corrector_type(idx_varnce_w_2) = 0;
varname_clubb(idx_varnce_w_2,1:10) = 'varnce_w_2';

% sigma_rr_1_n (-).
idx_count = idx_count + 1;
global idx_sigma_rr_1_n
idx_sigma_rr_1_n = idx_count;
units_corrector_type(idx_sigma_rr_1_n) = 0;
varname_clubb(idx_sigma_rr_1_n,1:12) = 'sigma_rr_1_n';

% sigma_rr_2_n (-).
idx_count = idx_count + 1;
global idx_sigma_rr_2_n
idx_sigma_rr_2_n = idx_count;
units_corrector_type(idx_sigma_rr_2_n) = 0;
varname_clubb(idx_sigma_rr_2_n,1:12) = 'sigma_rr_2_n';

% corr_w_rr_1_n (-).
idx_count = idx_count + 1;
global idx_corr_w_rr_1_n
idx_corr_w_rr_1_n = idx_count;
units_corrector_type(idx_corr_w_rr_1_n) = 0;
varname_clubb(idx_corr_w_rr_1_n,1:13) = 'corr_w_rr_1_n';

% corr_w_rr_2_n (-).
idx_count = idx_count + 1;
global idx_corr_w_rr_2_n
idx_corr_w_rr_2_n = idx_count;
units_corrector_type(idx_corr_w_rr_2_n) = 0;
varname_clubb(idx_corr_w_rr_2_n,1:13) = 'corr_w_rr_2_n';

% mixt_frac (-).
idx_count = idx_count + 1;
global idx_mixt_frac
idx_mixt_frac = idx_count;
units_corrector_type(idx_mixt_frac) = 0;
varname_clubb(idx_mixt_frac,1:9) = 'mixt_frac';

% precip_frac_1 (-).
idx_count = idx_count + 1;
global idx_precip_frac_1
idx_precip_frac_1 = idx_count;
units_corrector_type(idx_precip_frac_1) = 0;
varname_clubb(idx_precip_frac_1,1:13) = 'precip_frac_1';

% precip_frac_2 (-).
idx_count = idx_count + 1;
global idx_precip_frac_2
idx_precip_frac_2 = idx_count;
units_corrector_type(idx_precip_frac_2) = 0;
varname_clubb(idx_precip_frac_2,1:13) = 'precip_frac_2';

num_var_clubb = idx_count;

%============= Add Model Coordinates (Height and Time) Here ===============

% Altitude (meters)
idx_count = idx_count + 1;
global idx_z
idx_z = idx_count;
units_corrector_type(idx_z) = 0;
varname_clubb(idx_z,1:8) = 'altitude';

% Elapsed time (minutes)
idx_count = idx_count + 1;
global idx_time
units_corrector_type(idx_time) = 0;
idx_time = idx_count;
varname_clubb(idx_time,1:4) = 'time';

num_tot_var_clubb = idx_count;
