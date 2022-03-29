from cmath import pi
import numpy as np
import pandas as pd
import os
from matplotlib import pyplot as plt

def R_all_grains(df):
    # df is dataframe of data with pandas format 
    # grain_data = df.loc[df["feature_id"] == grain_id]
    A = df.loc[(df["feature_id"] >= 0) & (df["feature_volumes"] >= 0), ["feature_volumes"]]
    num_grain = len(A)
    # print(A)
    # <R> 1: SUM(R)/NUM
    a = np.sqrt(A/pi)
    # print(a)
    R_grain_1 = sum(a.values)/len(A)
    R_grain_1 = R_grain_1.tolist()
    # print(R_grain_1)

    # <R> 2: SUM(Ai/A*R)
    w = A/sum(A.values)
    R_grain_2_list = a*w
    # print(w)
    # print(R_grain_2_list)
    R_grain_2 = sum(R_grain_2_list.values)
    R_grain_2 = R_grain_2.tolist()

    # print(R_grain_2)
    return R_grain_1, R_grain_2, num_grain

def topology_moment(data):
    return

if __name__ == "__main__":
    # # 1. define root and csv_name
    # root = "./isotropicGB_Period2/"
    # time_csv_file = "out_isotropicGB_Period2.csv"
    # # "out_isotropicGB_Period2_grain_volumes_%04d.csv"
    # csv_file = "out_isotropicGB_Period2_grain_volumes_"
    # start_file_id = 0
    # end_file_id   = 411
    # output_csv_name = "Result_isotropicGB_Period2"
    # ================================

    root = "./elasticAnisotropic_GBAnisotropic/" 
    time_csv_file = "out_elasticAnisotropic_GBAnisotropic.csv"
    # "out_elasticAnisotropic_GBAnisotropic_grain_volumes_%04d.csv"
    csv_file = "out_elasticAnisotropic_GBAnisotropic_grain_volumes_"
    start_file_id = 0
    end_file_id   = 104
    output_csv_name = "Result_elasticAnisotropic_GBAnisotropic"
    # ================================

    # 
    time_csv_file_path = os.path.join(root, time_csv_file)
    tf = pd.read_csv(time_csv_file_path)
    dt = tf["dt"]
    time = tf["time"]

    # 2. topology evolution of one time
    # F:\simulationResult\gbAnisotropyGrainGrowth2\csv\elasticAnisotropic_GBAnisotropic\out_elasticAnisotropic_GBAnisotropic.csv
    # calculate dA/dt
    column_names = ["file_id", "time", "All_num", "<R>_all_n",  "<R>_all_w", "grain_id", "R", "adjacent_num", "Area", "dA/dt"]
    df_new = pd.DataFrame(data=None, index=None, columns=column_names, dtype=None, copy=None)

    num = 0
    for time_id in range(start_file_id+1, end_file_id+1):
        csv_file_name_1 = "%s%04d.csv" % (csv_file, (time_id-1) )
        csv_file_name_2 = "%s%04d.csv" % (csv_file, time_id)

        csv_file_path_1 = os.path.join(root, csv_file_name_1)
        csv_file_path_2 = os.path.join(root, csv_file_name_2)
        print(csv_file_path_2)

        # read data
        df1 = pd.read_csv(csv_file_path_1)
        df2 = pd.read_csv(csv_file_path_2)

        # average grain size this time
        R_mean_2_n, R_mean_2_w, num_grain = R_all_grains(df2)

        grain_id_2 = df2["feature_id"]

        for id in grain_id_2:
            if id >= 0:
                # print("[file %d grain %d]" % (time_id, id) )
                grain_2_inf = df2.loc[df2["feature_id"] == grain_id_2[id]]
                grain_1_inf = df1.loc[df1["feature_id"] == grain_id_2[id]]
                A2 = grain_2_inf["feature_volumes"].values
                n2_adjacent = grain_2_inf["adjacent_num"].values
                dA = grain_2_inf["feature_volumes"].values - grain_1_inf["feature_volumes"].values
                dA_dt = dA/dt[time_id]
                R2 = np.sqrt(A2/pi)
                df_new.loc["%d" % num, ["file_id", "time", "All_num", "<R>_all_n", "<R>_all_w", "grain_id", "R", "adjacent_num", "Area", "dA/dt"]] \
                                    = [time_id, time[time_id], num_grain, R_mean_2_n[0], R_mean_2_w[0], grain_id_2[id], R2[0], n2_adjacent[0], A2[0], dA_dt[0]]
                # print(df_new)
                num += 1
    # end of for

    # save results
    os.makedirs('results', exist_ok=True)  
    df_new.to_csv('./results/%s.csv' % output_csv_name)

    exit(0)