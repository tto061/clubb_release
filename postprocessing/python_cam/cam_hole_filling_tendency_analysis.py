#
# cam_hole_filling_analysis.py
# 
# Description: Under construction


import netCDF4
import numpy as np
import matplotlib.pyplot as plt

outdir = "./"
out_filename_tavg = "clip_tend_tavg"
out_filename_zavg = "clip_tend_zavg"
out_filetype =".png"


l_show_plots = False

### Function Definitions ###

#----------------------------------------------------------
def get_2d_profile(nc_file, var_name):
#
# Reads a 2d profile (time,lev) from a Scam data file 
#
#----------------------------------------------------------
    import numpy as np

    var = nc_file.variables[var_name]
    var = np.squeeze(var)

    return var
#----------------------------------------------------------

#----------------------------------------------------------
def plot_z_profile(ax, data_label, data, lev,):
#
# Creates a time average of a 2 dimensional (time, lev) array
# and plots the resulting profile. 
#
#----------------------------------------------------------
    import numpy as np

    ax.plot(data,lev,'b-',[0,0],[0,np.max(lev)],'r--')
    ax.set_xlabel(data_label)
    ax.set_ylabel('Altitude [m]')
#----------------------------------------------------------

#----------------------------------------------------------
def plot_t_profile(title, data_label, data, out_filepath):
#
# Creates a time average of a 2 dimensional (time, lev) array
# and plots the resulting profile. 
#
#----------------------------------------------------------
    import numpy as np
    import matplotlib.pyplot as plt

    fig = plt.figure()
    fig.text(.5,.95,title,horizontalalignment='center',)
    plt.plot(range(2001), data)
    plt.ylabel(data_label)
    plt.xlabel('Time [days]')
    fig.savefig(out_filepath)
    plt.close()
#----------------------------------------------------------

### Main script starts here ###

# CAM data file
nc_file_path = './camclubb19_L30_T1200.cam.h0.0001-01-01-00000.nc'

nc = netCDF4.Dataset(nc_file_path)

# Grid cell altitudes
lev = nc.variables['lev']
nlev = len(lev)
print(nlev)

# Calculate the inverse of each grid cell height (for averaging over z)
invers_dz = range(0,nlev)
invers_dz[0] = 1/lev[0]
for i in range(1,nlev):
    invers_dz[i] = 1/(lev[i]-lev[i-1])

#rho = get_2d_profile(nc,'rho_ds_zt')
#
#print(len(rho))

# It should be weights = rho_ds/invers_dz like in vertical_integral
wghts = invers_dz

print('---- Test: weights should add to 1 ----')
print(np.sum(wghts))

ice_clip_tend = get_2d_profile(nc,'INEGCLPTEND')
ice_clip_tend_tavg = np.average(ice_clip_tend, axis=0)

liq_clip_tend = get_2d_profile(nc,'LNEGCLPTEND')
liq_clip_tend_tavg = np.average(liq_clip_tend, axis=0)

vap_clip_tend = get_2d_profile(nc,'VNEGCLPTEND')
vap_clip_tend_tavg = np.average(vap_clip_tend, axis=0)

# Plot profiles
title='CAM-CLUBB-SILHS clipping budgets'

fig = plt.figure()
fig.text(.5,.95,title,horizontalalignment='center',)

ax1 = plt.subplot2grid((2, 2), (0, 0))
ax2 = plt.subplot2grid((2, 2), (0, 1))
ax3 = plt.subplot2grid((2, 2), (1, 0))
ax4 = plt.subplot2grid((2, 2), (1, 1))

plot_z_profile(ax1,'INEGCLPTEND', ice_clip_tend_tavg,lev)
plot_z_profile(ax2,'LNEGCLPTEND', liq_clip_tend_tavg,lev)
plot_z_profile(ax3,'VNEGCLPTEND', vap_clip_tend_tavg,lev)
plot_z_profile(ax4,'Sum', ice_clip_tend_tavg+liq_clip_tend_tavg+vap_clip_tend_tavg,lev)

fig.savefig(outdir+out_filename_tavg+out_filetype)

if ( l_show_plots ):
   plt.show()


# Plot timelines of height averages
levavg_sum = np.average(ice_clip_tend+liq_clip_tend+vap_clip_tend, axis=1, weights=wghts)
levavg_vap = np.average(vap_clip_tend, axis=1, weights=wghts)
levavg_liq = np.average(liq_clip_tend, axis=1, weights=wghts)
levavg_ice = np.average(ice_clip_tend, axis=1, weights=wghts)

print("---- Total ----")
print("Sum: "+str(np.sum(levavg_sum)))
print("Vap: "+str(np.sum(levavg_vap)))
print("Liq: "+str(np.sum(levavg_liq)))
print("Ice: "+str(np.sum(levavg_ice)))

title = 'Sum of Vapor/Ice/Liquid mixing ratio tendencies due to hole filling (total)'
label = 'Mixing ratios (Sum)'
out_filepath = outdir+out_filename_zavg+"_sum"+out_filetype
plot_t_profile(title, label, levavg_sum, out_filepath)

title = 'Vapor mixing ratio tendencies due to hole filling (total)'
label = 'Vapor mixing ratio'
out_filepath = outdir+out_filename_zavg+"_vap"+out_filetype
plot_t_profile(title, label, levavg_vap, out_filepath)

title = 'Cloud liquid mixing ratio tendencies due to hole filling (total)'
label = 'Cloud liquid mixing ratio'
out_filepath = outdir+out_filename_zavg+"_liq"+out_filetype
plot_t_profile(title, label, levavg_liq, out_filepath)

title = 'Cloud ice mixing ratio tendencies due to hole filling (total)'
label = 'Cloud ice mixing ratio'
out_filepath = outdir+out_filename_zavg+"_ice"+out_filetype
plot_t_profile(title, label, levavg_ice, out_filepath)


# Plot profiles of clipping tendencies due to vertical hole filling
ice_clip_tend_vhf = get_2d_profile(nc,'INEGCLPTEND_VHF')
liq_clip_tend_vhf = get_2d_profile(nc,'LNEGCLPTEND_VHF')

levavg_sum_vhf = np.average(ice_clip_tend_vhf+liq_clip_tend_vhf, axis=1, weights=wghts)
levavg_liq_vhf = np.average(liq_clip_tend_vhf, axis=1, weights=wghts)
levavg_ice_vhf = np.average(ice_clip_tend_vhf, axis=1, weights=wghts)

print("---- VertHF ----")
print("Sum: "+str(np.sum(levavg_sum_vhf)))
print("Liq: "+str(np.sum(levavg_liq_vhf)))
print("Ice: "+str(np.sum(levavg_ice_vhf)))

title = 'Sum of Vapor/Ice/Liquid mixing ratio tendencies due to vertical hole filling'
label = 'Mixing ratios (Sum)'
out_filepath = outdir+out_filename_zavg+"_sum_vhf"+out_filetype
plot_t_profile(title, label, levavg_sum_vhf, out_filepath)

title = 'Cloud liquid mixing ratio tendencies due to vertical hole filling'
label = 'Cloud liquid mixing ratio'
out_filepath = outdir+out_filename_zavg+"_liq_vhf"+out_filetype
plot_t_profile(title, label, levavg_liq_vhf, out_filepath)

title = 'Cloud ice mixing ratio tendencies due to vertical hole filling'
label = 'Cloud ice mixing ratio'
out_filepath = outdir+out_filename_zavg+"_ice_vhf"+out_filetype
plot_t_profile(title, label, levavg_ice_vhf, out_filepath)


# Plot profiles of clipping tendencies due to water vapor hole filling
ice_clip_tend_whf = get_2d_profile(nc,'INEGCLPTEND_WHF')
liq_clip_tend_whf = get_2d_profile(nc,'LNEGCLPTEND_WHF')

levavg_sum_whf = np.average(ice_clip_tend_whf+liq_clip_tend_whf, axis=1, weights=wghts)
levavg_liq_whf = np.average(liq_clip_tend_whf, axis=1, weights=wghts)
levavg_ice_whf = np.average(ice_clip_tend_whf, axis=1, weights=wghts)

print("---- WVHF ----")
print("Sum: "+str(np.sum(levavg_sum_whf)))
print("Liq: "+str(np.sum(levavg_liq_whf)))
print("Ice: "+str(np.sum(levavg_ice_whf)))

title = 'Sum of Vapor/Ice/Liquid mixing ratio tendencies due to water vapor hole filling'
label = 'Mixing ratios (Sum)'
out_filepath = outdir+out_filename_zavg+"_sum_whf"+out_filetype
plot_t_profile(title, label, levavg_sum_whf, out_filepath)

title = 'Cloud liquid mixing ratio tendencies due to water vapor hole filling'
label = 'Cloud liquid mixing ratio'
out_filepath = outdir+out_filename_zavg+"_liq_whf"+out_filetype
plot_t_profile(title, label, levavg_liq_whf, out_filepath)

title = 'Cloud ice mixing ratio tendencies due to water vapor hole filling'
label = 'Cloud ice mixing ratio'
out_filepath = outdir+out_filename_zavg+"_ice_whf"+out_filetype
plot_t_profile(title, label, levavg_ice_whf, out_filepath)

# Plot profiles of clipping tendencies due to clipping
ice_clip_tend_clp = get_2d_profile(nc,'INEGCLPTEND_CLP')
liq_clip_tend_clp = get_2d_profile(nc,'LNEGCLPTEND_CLP')

levavg_sum_clp = np.average(ice_clip_tend_clp+liq_clip_tend_clp, axis=1, weights=wghts)
levavg_liq_clp = np.average(liq_clip_tend_clp, axis=1, weights=wghts)
levavg_ice_clp = np.average(ice_clip_tend_clp, axis=1, weights=wghts)

print("---- CLIP ----")
print("Sum: "+str(np.sum(levavg_sum_clp)))
print("Liq: "+str(np.sum(levavg_liq_clp)))
print("Ice: "+str(np.sum(levavg_ice_clp)))

title = 'Sum of Vapor/Ice/Liquid mixing ratio tendencies due to clipping'
label = 'Mixing ratios (Sum)'
out_filepath = outdir+out_filename_zavg+"_sum_clp"+out_filetype
plot_t_profile(title, label, levavg_sum_clp, out_filepath)

title = 'Cloud liquid mixing ratio tendencies due to clipping'
label = 'Cloud liquid mixing ratio'
out_filepath = outdir+out_filename_zavg+"_liq_clp"+out_filetype
plot_t_profile(title, label, levavg_liq_clp, out_filepath)

title = 'Cloud ice mixing ratio tendencies due to clipping'
label = 'Cloud ice mixing ratio'
out_filepath = outdir+out_filename_zavg+"_ice_clp"+out_filetype
plot_t_profile(title, label, levavg_ice_clp, out_filepath)

# Plot profiles of clipping tendencies due to rest
ice_clip_tend_rst = get_2d_profile(nc,'INEGCLPTEND_RST')
liq_clip_tend_rst = get_2d_profile(nc,'LNEGCLPTEND_RST')

levavg_sum_rst = np.average(ice_clip_tend_rst+liq_clip_tend_rst, axis=1, weights=wghts)
levavg_liq_rst = np.average(liq_clip_tend_rst, axis=1, weights=wghts)
levavg_ice_rst = np.average(ice_clip_tend_rst, axis=1, weights=wghts)

print("---- REST ----")
print("Sum: "+str(np.sum(levavg_sum_rst)))
print("Liq: "+str(np.sum(levavg_liq_rst)))
print("Ice: "+str(np.sum(levavg_ice_rst)))

title = 'Sum of Vapor/Ice/Liquid mixing ratio tendencies due to clipping'
label = 'Mixing ratios (Sum)'
out_filepath = outdir+out_filename_zavg+"_sum_rst"+out_filetype
plot_t_profile(title, label, levavg_sum_rst, out_filepath)

title = 'Cloud liquid mixing ratio tendencies due to clipping'
label = 'Cloud liquid mixing ratio'
out_filepath = outdir+out_filename_zavg+"_liq_rst"+out_filetype
plot_t_profile(title, label, levavg_liq_rst, out_filepath)

title = 'Cloud ice mixing ratio tendencies due to clipping'
label = 'Cloud ice mixing ratio'
out_filepath = outdir+out_filename_zavg+"_ice_rst"+out_filetype
plot_t_profile(title, label, levavg_ice_rst, out_filepath)

print('---- TEST (should be all zero) ----')
print(np.sum(levavg_sum_vhf)+np.sum(levavg_sum_whf)+np.sum(levavg_sum_clp)+np.sum(levavg_sum_rst)-np.sum(levavg_sum)+np.sum(levavg_vap))
print(np.sum(levavg_liq_vhf)+np.sum(levavg_liq_whf)+np.sum(levavg_liq_clp)+np.sum(levavg_liq_rst)-np.sum(levavg_liq))
print(np.sum(levavg_ice_vhf)+np.sum(levavg_ice_whf)+np.sum(levavg_ice_clp)+np.sum(levavg_ice_rst)-np.sum(levavg_ice))

# Those profiles should match
fig = plt.figure()
fig.text(.5,.95,title,horizontalalignment='center',)
plt.plot(range(2001), levavg_vap)
plt.plot(range(2001), -levavg_sum_whf, 'ro')
fig.savefig(outdir+out_filename_zavg+"_test"+out_filetype)


fig = plt.figure()
fig.text(.5,.95,title,horizontalalignment='center',)
plt.plot(range(2001), levavg_sum-levavg_vap)
plt.plot(range(2001), levavg_sum_vhf+levavg_sum_whf+levavg_sum_clp+levavg_sum_rst, 'ro')
fig.savefig(outdir+out_filename_zavg+"_test2"+out_filetype)


fig = plt.figure()
fig.text(.5,.95,title,horizontalalignment='center',)

liq_clip_tend_vhf_tavg = np.average(liq_clip_tend_vhf, axis=0)
liq_clip_tend_whf_tavg = np.average(liq_clip_tend_whf, axis=0)
liq_clip_tend_clp_tavg = np.average(liq_clip_tend_clp, axis=0)
liq_clip_tend_rst_tavg = np.average(liq_clip_tend_rst, axis=0)

plt.plot(liq_clip_tend_tavg, range(nlev))
plt.plot(liq_clip_tend_vhf_tavg+liq_clip_tend_whf_tavg+liq_clip_tend_clp_tavg+liq_clip_tend_rst_tavg, range(nlev),'r--')

fig.savefig(outdir+out_filename_tavg+"_compare_liq"+out_filetype)

fig = plt.figure()
fig.text(.5,.95,title,horizontalalignment='center',)

ice_clip_tend_vhf_tavg = np.average(ice_clip_tend_vhf, axis=0)
ice_clip_tend_whf_tavg = np.average(ice_clip_tend_whf, axis=0)
ice_clip_tend_clp_tavg = np.average(ice_clip_tend_clp, axis=0)
ice_clip_tend_rst_tavg = np.average(ice_clip_tend_rst, axis=0)

plt.plot(ice_clip_tend_tavg, range(nlev))
plt.plot(ice_clip_tend_vhf_tavg+ice_clip_tend_whf_tavg+ice_clip_tend_clp_tavg+ice_clip_tend_rst_tavg, range(nlev),'r--')

fig.savefig(outdir+out_filename_tavg+"_compare_ice"+out_filetype)


if ( l_show_plots ):
   plt.show()

