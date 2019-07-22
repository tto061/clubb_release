from pyplotgen.Case import Case
from pyplotgen.DataReader import DataReader
from pyplotgen.VariableGroupBase import VariableGroupBase
from pyplotgen.VariableGroupCorrelations import VariableGroupCorrelations
from pyplotgen.VariableGroupIceMP import VariableGroupIceMP
from pyplotgen.VariableGroupKKMP import VariableGroupKKMP
from pyplotgen.VariableGroupLiquidMP import VariableGroupLiquidMP
from pyplotgen.VariableGroupWs import VariableGroupWs


class Case_jun25_altocu(Case):
    '''

    '''
    name = 'jun25_altocu'
    def __init__(self, ncdf_files, plot_sam = True):
        '''

        '''
        sec_per_min = 60
        self.start_time = 181 #* sec_per_min
        self.end_time = 240 #   * sec_per_min
        self.height_min_value = 4808
        self.height_max_value = 7308
        self.enabled = True
        self.ncdf_files = ncdf_files
        self.blacklisted_variables = ['Ngm', 'wprrp','wpNrp']
        sam_file = None
        # TODO LES file unknown
        # if plot_sam:
        #     datareader = DataReader()
        #     sam_file = datareader.__loadNcFile__(
        #         "/home/nicolas/sam_benchmark_runs/TWP_ICE_r1315_128x128x128_1km_Morrison/TWP_ICE.nc")
        base_variables = VariableGroupBase(self.ncdf_files, self, sam_file=sam_file)
        # w_variables = VariableGroupWs(self.ncdf_files, self, sam_file=sam_file)
        ice_variables = VariableGroupIceMP(self.ncdf_files, self, sam_file=sam_file)
        liquid_variables = VariableGroupLiquidMP(self.ncdf_files, self, sam_file=sam_file)
        # corr_variables = VariableGroupCorrelations(self.ncdf_files, self, sam_file=sam_file)
        # kk_variables = VariableGroupKKMP(self.ncdf_files, self, sam_file=sam_file)

        self.panel_groups = [base_variables, ice_variables, liquid_variables]
        self.panels = []

        for panelgroup in self.panel_groups:
            for panel in panelgroup.panels:
                self.panels.append(panel)