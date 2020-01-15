"""
:author: Nicolas Strike
:date: Mid 2019
"""

from src.VariableGroup import VariableGroup


class VariableGroupCorrelations(VariableGroup):

    def __init__(self, ncdf_datasets, case, sam_file=None, coamps_file=None, r408_dataset=None, hoc_dataset=None,
                 e3sm_datasets=None):

        self.name = "w variables"
        self.variable_definitions = [
            {'var_names': ['corr_w_rr_1']},
            {'var_names': ['corr_w_Nr_1']},
            {'var_names': ['corr_w_Ncn_1']},
            {'var_names': ['corr_chi_rr_1']},
            {'var_names': ['corr_chi_Nr_1']},
            {'var_names': ['corr_chi_Ncn_1']},
            {'var_names': ['corr_rr_Nr_1']},

        ]
        super().__init__(ncdf_datasets, case, sam_file=sam_file, coamps_file=coamps_file, r408_dataset=r408_dataset, hoc_dataset=hoc_dataset, e3sm_datasets= e3sm_datasets)