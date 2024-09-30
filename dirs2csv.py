#!/usr/bin/env python3
import os, json
import sys, getopt


def main(argv):
   inputdir = ''
   outputfile = ''
   try:
      opts, args = getopt.getopt(argv,"hi:o:",["idir=","ofile="])
   except getopt.GetoptError:
      print ('dirs2csv.py -i <inputdir> -o <outputcsv>')
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print ('dirs2csv.py -i <inputdir> -o <outputcsv>')
         sys.exit()
      elif opt in ("-i", "--idir"):
         inputdir = arg
      elif opt in ("-o", "--ofile"):
         outputfile = arg
   if inputdir == '':
      print("Error: no input dir specified with -i")
      sys.exit(-1)
   if not os.path.isdir(inputdir):
      print("Error: input direction does not exist")
      sys.exit(-1)
      
   if outputfile == '':
      print("Error: no output file specified with -o")
      sys.exit(-1)

   header = {}
   rows = []
   cache = {}
   for root, dirs, files in os.walk(inputdir, topdown=False):
      for name in files:
         # do each directory only once
         if root in cache:
            continue
         else:
            cache[root] = True
         s = root.split("/")
         v = {}
         for e in s:
            es = e.split("_")
            header[es[0]] = True
            v[es[0]] = "_".join(es[1:])
         rows.append(v)
   if outputfile.endswith(".json"):
      with open(outputfile,"w") as f:
         json.dump(rows,f)
      sys.exit(0)
   else:
      # assume we have a csv file to export
      import csv
      with open(outputfile, 'w', newline='') as csvfile:
         writer = csv.writer(csvfile, delimiter=',',quotechar='"', quoting=csv.QUOTE_MINIMAL)
         writer.writerow(header.keys())
         for row in rows:
            r = []
            for h in header.keys():
               if h in row:
                  r.append(row[h])
               else:
                  r.append("")
            writer.writerow(r)
         
if __name__ == "__main__":
   main(sys.argv[1:])


