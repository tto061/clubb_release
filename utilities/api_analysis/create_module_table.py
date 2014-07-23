import os, sys, fileinput
from api_commitment_test import findFiles, arrayOfFileNames

# ~~~~~~ Create Module Table ~~~~~~ schemenauero ~~~~~~ 7/02/14 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# When ran in a folder which also has module lists, this script returns 
# an html table of which modules are used in which list

def formatBool(boolean):
    retStr = ""
    if (boolean):
        retStr = "<td>"+str(boolean)+"</td>"
    else:
        retStr = "<td style='color:lightgrey'>"+str(boolean)+"</td>"
    return retStr

def getClubbCoreModules(clubbCoreLocation):
    retVals = []
    for mod in arrayOfFileNames(findFiles(clubbCoreLocation)):
        if ".svn-base" not in mod:
            retVals.append(mod)
    return retVals

# Setup Input
try:
    tempString = sys.argv[1]
except Exception:
    print "Missing Argument: CLUBB_core location"

# Create data lists
clubb_standalone = []
clubb_core = []
sam = []
wrf = []
cam = []

# Read in modules
with open("clubb_standalone_modules.txt") as file:
    clubb_standalone = file.readlines()

with open("clubb_core_modules.txt") as file:
    clubb_core = file.readlines()

with open("sam_modules.txt") as file:
    sam = file.readlines()

with open("wrf_modules.txt") as file:
    wrf = file.readlines()

with open("cam_modules.txt") as file:
    cam = file.readlines()

# Make a master set and list
moduleSet = set()
modules = []

# Add the modules in clubb core
for mod in getClubbCoreModules(sys.argv[1]):
    moduleSet.add(str(mod)+"\n")

modules = list(moduleSet)

# Sort the master list alphabetically
modules.sort(key=lambda string: string.lower())

# Setup some table data
currentUsers = 0
usedByClubb = False
usedBySam = False
usedByWrf = False
usedByCam = False
usedByClubbCore = False
# Using "sortable" http://www.kryogenix.org/code/browser/sorttable/#symbolsbeforesorting
table =  '<!DOCTYPE html><html><script src="sorttable.js"></script>'
table += "<style>table,td, th{"
table += "border:1px solid black;"
table += "border-collapse: collapse;"
table += "}"
table += "th {"
table += "background-color: lightgrey;"
table += "}</style>"
table += '<body><table class="sortable"><tr><th>Module Name</th>'
table += "<th># of Users</th><th>CLUBB_core</th><th>CLUBB_standalone</th>"
table += "<th>SAM</th><th>WRF</th><th>CAM</th></tr>"

# Create the table
for module in modules:
    currentUsers = 0
    usedByClubbStandalone = False
    usedBySam = False
    usedByWrf = False
    usedByCam = False
    usedByClubbCore = False

    if module in clubb_standalone:
        usedByClubbStandalone = True
        currentUsers += 1

    if module in sam:
        usedBySam = True
        currentUsers += 1

    if module in wrf:
        usedByWrf = True
        currentUsers += 1

    if module in cam:
        usedByCam = True
        currentUsers += 1

    if module in clubb_core:
        usedByClubbCore = True
        currentUsers += 1

    table += "<tr><td>"+module+"</td>"
    table += "<td>"+str(currentUsers)+"</td>"
    table += formatBool(usedByClubbCore)
    table += formatBool(usedByClubbStandalone)
    table += formatBool(usedBySam)
    table += formatBool(usedByWrf)
    table += formatBool(usedByCam)+"</tr>"

table += "</table></body></html>"

print table