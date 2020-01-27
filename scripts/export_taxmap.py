# "C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python" export_taxmap.py "C:/taxmap.sde" "D:/temp" 
import arcpy
import os
import sys

# todo: externalize for use in other stratum repos
fcs = {'DOF_TAXMAP.Cadastral\DOF_TAXMAP.Tax_Lot_Polygon': 'Tax_Lot_Polygon',
       'DOF_TAXMAP.Cadastral\DOF_TAXMAP.Tax_Block_Polygon': 'Tax_Block_Polygon'} 


def exportshps(psde
              ,pdirectory):

    for fc, shapefile in fcs.items():

        featureclass = os.path.join(psde
                                   ,fc)

        shp = "".join([shapefile, '.shp'])

        msg = "Exporting {0} to {1}".format(featureclass
                                           ,pdirectory)
        print(msg)

        arcpy.FeatureClassToFeatureClass_conversion(featureclass
                                                   ,pdirectory
                                                   ,shp)

        msg = "Finished exporting {0}".format(shp)
        print(msg)

    return 1



if __name__ == "__main__":

    if len(sys.argv) != 3:
        msg = "I {0} request but 2 inputs, the test sde file and an output ".format(sys.argv[0])
        msg += "directory. Instead I have been given {0} inputs".format(len(sys.argv) - 1)                                                   
        print (msg)                                                                        
        raise ValueError(msg)

    psde = sys.argv[1]   
    pdirectory = sys.argv[2]

    if not os.path.isfile(psde):
        msg = "I cannot find the expected sde file at {0}".format(psde)
        print (msg)
        raise ValueError(msg)


    if not os.path.isdir(pdirectory):
        msg = "I cannot find the expected output directory at {0}".format(psde)
        print (msg)
        raise ValueError(msg)

    exitval = exportshps(psde
                        ,pdirectory)

    msg = "Peace out"

    sys.exit(exitval)